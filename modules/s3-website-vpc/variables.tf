variable "app_name" { type = string }
variable "domain" { type = string }
variable "dns_zone_name" { type = string }
variable "subnets" { type = list(any) }
variable "tags" { type = map(any) }
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
