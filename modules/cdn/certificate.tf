data "aws_route53_zone" "zone" {
  count = var.dns_zone_id == null ? 1 : 0
  name  = var.dns_zone
}

locals {
  zone_id             = var.dns_zone_id != null ? var.dns_zone_id : data.aws_route53_zone.zone[0].zone_id
  certificate_enabled = coalesce(var.certificate_enable, true)
}

resource "aws_acm_certificate" "cert" {
  for_each = local.certificate_enabled ? { default = true } : {}

  domain_name       = var.certificate_name != null ? var.certificate_name : var.host
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.certificate_enabled ? {
    for dvo in aws_acm_certificate.cert["default"].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = var.ttl
  allow_overwrite = var.allow_overwrite
}

resource "aws_acm_certificate_validation" "cert" {
  for_each = local.certificate_enabled ? { default = true } : {}

  certificate_arn         = aws_acm_certificate.cert["default"].arn
  validation_record_fqdns = values(aws_route53_record.cert_validation)[*].fqdn
}
