
################################################################################
# VARIABLES
################################################################################


### REQUIRED VARIABLES
variable "cluster_name" {}

variable "vpc_id" {}

variable "subnet_ids" {}



### OPTIONAL VARIABLES


variable "control_plane_subnet_ids" {
  default = [] 
}

variable "cluster_addons" {
  default = {}
}
variable "eks_managed_node_group_defaults" {
  default = {}
}

variable "access_entries" {
  default = {}
}

variable "eks_managed_node_groups" {
  default = {}
}
variable "cluster_endpoint_public_access" {
  default = false
}

variable "cluster_endpoint_private_access" {
  default = true
}

variable "cluster_version" {
  default = "1.30"
}

variable "cluster_ip_family" {
  default = "ipv4"
}

variable "create_cni_ipv6_iam_policy" {
  default = false
}

variable "cluster_enabled_log_types" {
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  default = 30
}


variable "enable_cluster_creator_admin_permissions" {
  default = true
}

variable "authentication_mode" {
  default = "API"
}

variable "cluster_additional_security_group_ids" {
  default = []
}


variable "enable_irsa" {
  default = true
}


variable "tags" {
  default = {}
}

variable "cluster_tags" {
  default = {}
}

variable "environment" {
  default = "dev"
}
