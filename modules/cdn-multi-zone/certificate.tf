locals {
  certificate_domain_name = var.certificate_name != null ? var.certificate_name : var.host
  certificate_subject_alternative_names = distinct([
    for name in var.custom_cname : name
    if name != local.certificate_domain_name
  ])
}

data "aws_route53_zone" "zone" {
  name = var.dns_zone
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.certificate_domain_name
  subject_alternative_names = local.certificate_subject_alternative_names
  validation_method         = "DNS"
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
      zone_id = lookup(var.certificate_validation_zone_ids, dvo.domain_name, data.aws_route53_zone.zone.zone_id)
    }
  }

  zone_id         = each.value.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = var.ttl
  allow_overwrite = var.allow_overwrite
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
