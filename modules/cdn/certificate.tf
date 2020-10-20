
data "aws_route53_zone" "zone" {
  name = var.dns_zone
}

// Create ACM Certificate for SSL
resource "aws_acm_certificate" "cert" {
  domain_name       = var.host
  validation_method = "DNS"
  tags              = var.tags
}

// Create Route53 record to validate certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for c in aws_acm_certificate.cert.domain_validation_options : c.domain_name => {
      name    = c.resource_record_name
      type    = c.resource_record_type
      record  = c.resource_record_value
      ttl     = 60
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id

}

// Create validation to validate certificate based on the Route53 record
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
