data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_api_gateway_rest_api" "api-escale" {
  name = var.api_gateway_name
}

data "aws_api_gateway_vpc_link" "vpc_link_ecs_apps" {
  name = var.api_gateway_vpc_link_name
}

data "aws_acm_certificate" "xclapi" {
  domain      = var.api_gateway_certificate_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "xclapi" {
  name = var.api_gateway_zone_name
}
