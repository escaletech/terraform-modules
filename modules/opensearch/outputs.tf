output "opensearch_endpoint" {
  value       = aws_opensearch_domain.opensearch.arn
  description = "OpenSearch domain endpoint"
}

output "opensearch_arn" {
  value       = aws_opensearch_domain.opensearch.arn
  description = "OpenSearch domain ARN"
}

output "opensearch_domain_name" {
  value       = aws_opensearch_domain.opensearch.domain_name
  description = "OpenSearch domain name"
}

output "snapshot_backup_role_arn" {
  value       = aws_iam_role.OpenSearch_Snapshot_Backup.arn
  description = "ARN of snapshot backup role"
}