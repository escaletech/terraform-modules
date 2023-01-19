resource "aws_acm_certificate" "certificate" {
  domain_name       = local.domain
  validation_method = "DNS"
  tags              = local.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "domain" {
  name    = local.domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  depends_on = [
    aws_route53_record.domain
  ]
}