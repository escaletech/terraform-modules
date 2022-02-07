output "arn" {
  description = "the RDS instance ARN"
  value       = module.escale-rds.arn
}

output "endpoint" {
  description = "the RDS instance endpoint"
  value       = module.escale-rds.endpoint
}

output "https_listener_arn" {
  description = "endpoint listener arn"
  value       = aws_lb_listener.internal_https.arn
}

output "target_group_arn" {
  description = "target group arn"
  value       = aws_lb_target_group.internal.arn
}
