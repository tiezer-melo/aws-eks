
################################################################################
# VARIABLES
################################################################################


### REQUIRED VARIABLES
variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
}



### OPTIONAL VARIABLES


variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  default = [] 
}

variable "cluster_addons" {
    description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"

  default = {}
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  default = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  default = {}
}

variable "access_entries" {
    description = "Map of access entries to add to the cluster"
  default = {}
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default = false
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default = true
}

variable "cluster_version" {
    description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.30`)"
  default = "1.30"
}

variable "cluster_ip_family" {
    description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  default = "ipv4"
}

variable "create_cni_ipv6_iam_policy" {
  description = "Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy)"
  default = false
}

variable "cluster_enabled_log_types" {
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  default = 30
}


variable "enable_cluster_creator_admin_permissions" {
    description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  default = true
}

variable "authentication_mode" {
    description = "The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP`"
  default = "API"
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  default = []
}


variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  default = true
}


variable "tags" {
  description = "A map of tags to add to all resources"
  default = {}
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  default = {}
}