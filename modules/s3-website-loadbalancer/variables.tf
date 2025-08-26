variable "domain" { type = string }
variable "subnets" { type = list(any) }
variable "vpc_name" { type = string }
data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_default_tags" "escale-default-tags" {}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "sg-name" {
  type    = string
  default = null
}

resource "null_resource" "check-tags" {
  lifecycle {
    precondition {
      condition     = length(var.tags) != 0 || length(data.aws_default_tags.escale-default-tags.tags) != 0
      error_message = "Tags are required!"
    }
  }
}
