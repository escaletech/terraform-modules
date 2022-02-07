output "arn" {
  description = "the RDS instance ARN"
  value       = aws_db_instance.db.arn
}

output "endpoint" {
  description = "the RDS instance endpoint"
  value       = aws_db_instance.db.endpoint
}