data "aws_route53_zone" "domain" {
  name         = local.domain
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.certificate_host
  validation_method         = "DNS"
  subject_alternative_names = [var.alternative_domain]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "tls-entry" {
  allow_overwrite = true
  name            = local.name
  records         = [local.record]
  ttl             = local.ttl
  type            = local.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "private-ingress" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
