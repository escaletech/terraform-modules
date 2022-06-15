resource "aws_acm_certificate" "certificate" {
  domain_name               = var.certificate_host
  validation_method         = "DNS"
  subject_alternative_names = var.alternative_domain

  lifecycle {
    create_before_destroy = true
  }
}

module "acm-multiple-domains" {
  for_each        = { for domain in aws_acm_certificate.certificate.domain_validation_options : domain.domain_name => domain }
  source          = "./terraform-aws-acm-multiple-domains"
  certificate_arn = aws_acm_certificate.certificate.arn
  domain          = each.key
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  record          = each.value.resource_record_value
  ttl             = 3600
}

resource "aws_acm_certificate_validation" "validate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for domain in module.acm-multiple-domains : domain.record.fqdn]
}
