output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the created VPC"
  value       = module.vpc.vpc_cidr_block
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "eso_role_arn" {
  value = module.eso_irsa.eso_role_arn
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data for the EKS cluster"
  value       = module.eks.cluster_ca_certificate
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider for the EKS cluster"
  value       = module.eks.oidc_provider_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "node_group_id" {
  description = "ID of the created EKS node group"
  value       = module.node_groups.node_group_id
}

output "node_group_arn" {
  description = "ARN of the created EKS node group"
  value       = module.node_groups.node_group_arn
}

output "ecr_repository_urls" {
  description = "Map of microservice names to ECR repository URLs"
  value       = module.ecr.ecr_repository_urls
}

output "lbc_role_arn" {
  value = module.lbc_oicd.lbc_role_arn
}
