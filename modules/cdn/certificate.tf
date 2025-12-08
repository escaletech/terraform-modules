data "aws_route53_zone" "zone" {
  name = var.dns_zone
}

resource "aws_acm_certificate" "cert" {
  count             = var.create_certificate ? 1 : 0
  domain_name       = var.host
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = var.create_certificate ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = var.ttl
  allow_overwrite = var.allow_overwrite
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = var.create_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
