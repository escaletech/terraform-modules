data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_acm_certificate" "default_domain" {
  domain      = var.default_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "additional_domains" {
  for_each    = toset(var.additional_domains)
  domain      = each.value
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
