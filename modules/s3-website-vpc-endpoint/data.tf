data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_acm_certificate" "domains" {
  for_each    = var.domains
  domain      = each.value
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
