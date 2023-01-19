resource "aws_api_gateway_domain_name" "custom_domain" {
  certificate_arn = aws_acm_certificate.certificate.arn
  domain_name     = local.domain
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name = local.name
}
