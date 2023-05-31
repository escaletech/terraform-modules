output "arn" {
  description = "the RDS instance ARN"
  value       = module.escale-rds.arn
}

output "endpoint" {
  description = "the RDS instance endpoint"
  value       = module.escale-rds.endpoint
}

output "certificate_arn" {
  description = "value of certificate arn"
  value       = aws_acm_certificate.certificate.arn
}

output "instance_ip" {
  description = "instance ip"
  value       = aws_instance.instance.private_ip
}
