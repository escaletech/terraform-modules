variable "subnets" { type = list(any) }
variable "tags" { type = map(any) }
variable "vpc_name" { type = string }
data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
