output "node_group_id" {
  description = "ID of the created EKS node group"
  value       = aws_eks_node_group.this[*].id
}

output "node_group_arn" {
  description = "ARN of the created EKS node group"
  value       = aws_eks_node_group.this[*].arn
}