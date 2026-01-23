output "arn" {
  description = "The ARN of the repository."
  value       = aws_ecr_repository.this.arn
}

output "url" {
  description = "The URL of the repository (fqdn)."
  value       = aws_ecr_repository.this.repository_url
}
