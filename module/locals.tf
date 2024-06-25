
################################################################################
# LOCALS
################################################################################
locals {
  ## CLUSTER LOGS
  cluster_enabled_log_types              = ["audit", "api", "authenticator"]

  ## DEFAULT WORKER NODES CONFIGURATION
  eks_managed_node_group_defaults = try(var.eks_managed_node_group_defaults, {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
    capacity_type  = "SPOT"

    use_custom_launch_template = false

    # Enables detailed monitoring for auto scaling group EC2 instances used as cluster worker nodes.
    enable_monitoring = true

    iam_role_additional_policies = {
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
  })

  ## CLUSTER ADDONS
  cluster_addons_defaults = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  cluster_addons = try(merge(var.cluster_addons, local.cluster_addons_defaults), local.cluster_addons_defaults)
}
