variable "vpc_name" {
  description = "The tag Name for the VPC resource"
  type        = string
}

variable "subnets" {
  description = <<EOD
    A map of subnets where the key is availability zone and the value the subnet name.
    Ex: {
      "us-east-1a" = "subnet-a"
      "us-east-1b" = "subnet-b"
    }
EOD
  type        = map(any)
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
