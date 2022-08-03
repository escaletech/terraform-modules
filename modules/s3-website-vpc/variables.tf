variable "app_name" { type = string }
variable "domain" { type = string }
variable "dns_zone_name" { type = string }
variable "subnets" { type = list(any) }
variable "vpc_name" { type = string }
variable "private_zone" {
  type    = bool
  default = false
}

variable "internal_ip" {
  type    = bool
  default = true
}

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_route53_zone" "zone" {
  name         = var.dns_zone_name
  private_zone = var.private_zone
}

data "aws_default_tags" "escale-default-tags" {}

variable "tags" {
  type    = map(any)
  default = {}
}

resource "null_resource" "check-tags" {
  lifecycle {
    precondition {
      condition     = length(var.tags) != 0 || length(data.aws_default_tags.escale-default-tags.tags) != 0
      error_message = "Tags are required!"
    }
  }
}