output "record_fqdn" {
  description = "Record FQDN."
  value       = aws_route53_record.dns.fqdn
}

output "record_id" {
  description = "Record ID."
  value       = aws_route53_record.dns.id
}
