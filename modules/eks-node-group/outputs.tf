output "arn" {
  value       = aws_eks_node_group.extra-node-group.arn
  description = "The ARN of the EKS node group"
}

output "id" {
  value       = aws_eks_node_group.extra-node-group.id
  description = "The ID of the EKS node group"
}

output "resources" {
  value       = aws_eks_node_group.extra-node-group.resources
  description = "The resources of the EKS node group"
}

output "tags_all" {
  value       = aws_eks_node_group.extra-node-group.tags_all
  description = "The tags of the EKS node group"
}

output "status" {
  value       = aws_eks_node_group.extra-node-group.status
  description = "The status of the EKS node group"
}
