# aws-eks
This module is based on the `terraform-aws-eks` module and provides an easy way to create an EKS cluster with a supporting VPC. The module allows configuration of the EKS cluster using variables, and it also defines default values using Terraform local variables to ensure reliable defaults and reduce user error.



## Features
- EKS Cluster: Deploys an EKS cluster with customizable settings.
- VPC Creation: Automatically creates a VPC to support the EKS cluster.
- Variable Configuration: Uses variables to configure the cluster with sensible defaults defined using Terraform local variables.
- Override Capability: Users can override the default values by specifying their own values for the variables.


## Usage

Below is an example of how to use this module in your Terraform configuration:

```hcl
module "cluster" {
  source = "./module"

  # Variables you need to declare
  cluster_name = "cluster"
  vpc_id       = "vpc-00000000000000000"
  subnet_ids   = ["subnet-11111111111111111","subnet-22222222222222222","subnet-33333333333333333"]
}

provider "aws" {
  region = var.region
}
```

The module assumes the use of the Terraform workspace feature to allow the use of the same code for different environments, as well as the possibility of making the code more dynamic if used in conjunction with tfvars. For the proposed example, the accepted values ​​for the workspace name are dev and prod. These values ​​will be used both to select one of the two predefined node groups and to assign the name of the cluster and VPC.

The workspace can be created and defined using the following commands, in which the workspace called prod will be used in the example:

```bash
$ terraform workspace new prod
$ terraform workspace select prod
```

After creating the module invocation file and configuring the terraform workspace, the commands below can be followed to deploy the resources on AWS:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```


A more complete example of the use of the module is presented below:
```hcl
module "cluster" {
  source = "./module"

  # Variables you need to declare
  cluster_name = "cluster"
  vpc_id       = "vpc-00000000000000000"
  subnet_ids   = ["subnet-11111111111111111","subnet-22222222222222222","subnet-33333333333333333"]

  # Optional Variables
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  eks_managed_node_groups ={
    example = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      use_custom_launch_template = true
      ami_type       = "AL2_x86_64"
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

      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      labels = {
        Environment = terraform.workspace
      }
    }
  }  
}

provider "aws" {
  region = var.region
}
```


## Variables
The module defines several variables to configure the EKS cluster. Below are some required variables with their descriptions:

- cluster_name: (Required) The name of the EKS cluster.
- vpc_id: (Required) ID of the VPC where the cluster security group will be provisioned
- subnet_ids: (Required) A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets


Default values for these variables are defined using Terraform locals to prevent user error.

A complete list of variables that can be overridden is available in the `variables.tf` file. Users are encouraged to review this file to understand all the configurable options.


## Notes
- Ensure you have the AWS provider configured in your Terraform project.
- Review the variables.tf file to understand all the configurable options and their default values.