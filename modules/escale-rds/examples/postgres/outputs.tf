output "arn" {
  description = "the RDS instance ARN"
  value       = module.escale-rds.arn
}

output "endpoint" {
  description = "the RDS instance endpoint"
  value       = module.escale-rds.endpoint
}