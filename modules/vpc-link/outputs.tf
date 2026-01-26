output "id" {
  description = "ID of the VPC Link."
  value       = aws_api_gateway_vpc_link.this.id
}

output "name" {
  description = "Name of the VPC Link."
  value       = aws_api_gateway_vpc_link.this.name
}

output "arn" {
  description = "ARN of the VPC Link."
  value       = aws_api_gateway_vpc_link.this.arn
}
