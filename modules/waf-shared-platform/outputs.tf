output "web_acl_arn" {
  description = "ARN do Web ACL. Usar em associations e no template Serverless anti-regressao."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "ID do Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_name" {
  description = "Nome do Web ACL."
  value       = aws_wafv2_web_acl.this.name
}

output "log_group_name" {
  description = "Log group de WAF (prefixo aws-waf-logs-)."
  value       = aws_cloudwatch_log_group.waf.name
}

output "log_group_arn" {
  description = "ARN do log group."
  value       = aws_cloudwatch_log_group.waf.arn
}

output "allow_ip_set_arn" {
  description = "ARN do IP set de allow (vazio no v1)."
  value       = aws_wafv2_ip_set.allow.arn
}

output "deny_ip_set_arn" {
  description = "ARN do IP set de deny (vazio no v1)."
  value       = aws_wafv2_ip_set.deny.arn
}

output "blocked_requests_alarm_name" {
  description = "Nome do alarme CloudWatch de BlockedRequests."
  value       = aws_cloudwatch_metric_alarm.blocked_requests.alarm_name
}
