terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

locals {
  # GENERAL
  region = "eu-west-1"
  name   = terraform.workspace
  tags = {
    Name  = local.name
    Owner = "ENTERPRISE"
  }



  # VPC
  vpc_cidr = "10.100.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  
  # EKS
  ## WORKER NODES CONFIGURATION
  pre_configured_managed_node_group = {
    dev = {
      core = {
        name         = "core-dev"
        min_size     = 1
        max_size     = 3
        desired_size = 2
      }
    }

    prod = {
      core = {
        name         = "core-prod"
        min_size     = 2
        max_size     = 6
        desired_size = 4

        use_custom_launch_template = false

        enable_monitoring = true

        iam_role_additional_policies = {
          AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
          AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
          AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        }

        instance_types = ["t3.medium"]
        capacity_type  = "ON_DEMAND"

        block_device_mappings = {
          xvda = {
            device_name = "/dev/xvda"
            ebs = {
              volume_size           = 20
              volume_type           = "gp3"
              iops                  = 3000
              throughput            = 100
              delete_on_termination = true
            }
          }
        }

        labels = {
          Environment = terraform.workspace
        }

        launch_template_tags = {
          # enable discovery of autoscaling groups by cluster-autoscaler
          "k8s.io/cluster-autoscaler/enabled" : true,
          "k8s.io/cluster-autoscaler/${local.name}" : "owned",
        }
      }
    }
  }
}


################################################################################
# EKS Module
################################################################################


data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}



module "cluster" {
  source  = "./module"


  enable_irsa = true

  cluster_name                             = local.name
  cluster_version                          = "1.30"
  enable_cluster_creator_admin_permissions = true


  # CLUSTER ACCESSES
  authentication_mode             = "API"
  access_entries                  = {}
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true


  # VPC CONFIGURATION
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_ip_family          = "ipv4"


  # CLUSTER LOGS
  cloudwatch_log_group_retention_in_days = "90"
  cluster_enabled_log_types              = ["audit", "api", "authenticator"]


  # ADDONS
  cluster_addons = {}

  # CUSTOM WORKER NODES

  eks_managed_node_group_defaults = {
    instance_types = ["m5.large"]
    ami_type       = "AL2_x86_64"
    capacity_type  = "ON_DEMAND"

    use_custom_launch_template = false

    # Enables detailed monitoring for auto scaling group EC2 instances used as cluster worker nodes.
    enable_monitoring = true
  }


  eks_managed_node_groups = local.pre_configured_managed_node_group[terraform.workspace]


  # TAGS
  cluster_tags = merge(local.tags, { "Name" : local.name })
  tags = merge(local.tags, { "Name" : local.name })
}




################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  private_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  intra_subnet_assign_ipv6_address_on_creation   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = merge(local.tags, { "Name" : local.name })
}

module "ebs_kms_key" {
  source   = "terraform-aws-modules/kms/aws"
  version  = "~> 2.1"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.cluster.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.name}/ebs"]

  tags = merge(local.tags, { "Name" : local.name })
}


