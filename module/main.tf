
################################################################################
# EKS Module
################################################################################

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"


  cluster_additional_security_group_ids = try(var.cluster_additional_security_group_ids, [])
  enable_irsa = try(var.enable_irsa, true)

  cluster_name                             = var.cluster_name
  cluster_version                          = try(var.cluster_version, "1.30")
  enable_cluster_creator_admin_permissions = try(var.enable_cluster_creator_admin_permissions, true)


  # CLUSTER ACCESSES
  authentication_mode             = try(var.authentication_mode, "API")
  access_entries                  = try(var.access_entries, {})
  cluster_endpoint_public_access  = try(var.cluster_endpoint_public_access, false)
  cluster_endpoint_private_access = try(var.cluster_endpoint_private_access, true)


  # VPC CONFIGURATION
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids


  # IPV6
  cluster_ip_family          = try(var.cluster_ip_family, "ipv4")
  create_cni_ipv6_iam_policy = try(var.create_cni_ipv6_iam_policy, "false")


  # CLUSTER LOGS
  cloudwatch_log_group_retention_in_days = try(var.cloudwatch_log_group_retention_in_days, 14)
  cluster_enabled_log_types              = try(var.cluster_enabled_log_types, local.cluster_enabled_log_types)


  # SECRETS ENCRYPTION
  cluster_encryption_config = {
    resources = ["secrets"]
  }


  # ADDONS
  cluster_addons = local.cluster_addons


  # WORKER NODES
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups = try(var.eks_managed_node_groups, {})


  # TAGS
  cluster_tags = var.cluster_tags
  tags = var.tags
}


