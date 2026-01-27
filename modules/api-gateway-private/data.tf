data "aws_route53_zone" "zone" {
  count        = var.create_route53_record ? 1 : 0
  name         = var.zone
  private_zone = var.private_zone
}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  count = var.create_vpc_endpoint ? 1 : 0
  id    = var.vpc_id
}
