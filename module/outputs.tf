################################################################################
# OUTPUTS
################################################################################
output "cluster_id" {
  description = "EKS cluster ID"
  value       = try(module.eks.cluster_id, null)
}

output "cluster_name" {
  description = "EKS cluster Name"
  value       = try(module.eks.cluster_name, null)
}

output "cluster_managed_nodegroups" {
  description = "EKS managed node groups"
  value       = try(module.eks.eks_managed_node_groups, null)
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = try("aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}", null)
}

output "cluster_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = try(module.eks.eks_managed_node_groups_autoscaling_group_names, null)
}


output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(module.eks.cluster_certificate_authority_data, null)
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks.cluster_endpoint, null)
}


output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = try(module.eks.cluster_oidc_issuer_url, null)
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(module.eks.cluster_platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(module.eks.cluster_status, null)
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = try(module.eks.cluster_security_group_id, null)
}

output "cluster_node_security_group_id" {
  description = "ID of the node shared security group"
  value       = try(module.eks.node_security_group_id, null)
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value = try(module.eks.cluster_primary_security_group_id, null)
}


################################################################################
# IRSA
################################################################################

output "cluster_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(module.eks.oidc_provider, null)
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(module.eks.oidc_provider_arn, null)
}


################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = try(module.eks.cluster_iam_role_name, null)
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = try(module.eks.cluster_iam_role_arn, null)
}