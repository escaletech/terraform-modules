output "opensearch_endpoint" {
  value       = aws_opensearch_domain.opensearch.endpoint
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

output "ccr_outbound_connection_id" {
  value       = local.ccr_enabled ? aws_opensearch_outbound_connection.ccr[0].id : null
  description = "CCR outbound connection ID"
}

output "ccr_outbound_connection_status" {
  value       = local.ccr_enabled ? aws_opensearch_outbound_connection.ccr[0].connection_status : null
  description = "CCR outbound connection status"
}

output "ccr_inbound_connection_id" {
  value       = local.ccr_accept_inbound ? aws_opensearch_inbound_connection_accepter.ccr[0].id : null
  description = "CCR accepted inbound connection ID"
}