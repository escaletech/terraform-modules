output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.platform_conversational.id
}

output "instance_private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.platform_conversational.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.opensource.id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.bucket-saas.bucket
}

output "target_group_arns" {
  description = "Target group ARNs by application name"
  value       = { for k, v in aws_lb_target_group.platform-conversational : k => v.arn }
}

