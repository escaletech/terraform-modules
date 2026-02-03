output "file_system_id" {
  description = "ID do EFS"
  value       = aws_efs_file_system.this.id
}

output "access_point_id" {
  description = "ID do Access Point"
  value       = aws_efs_access_point.this.id
}

output "security_group_id" {
  description = "Security Group do EFS"
  value       = aws_security_group.efs.id
}