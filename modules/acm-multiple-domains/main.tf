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
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "private-ingress" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
