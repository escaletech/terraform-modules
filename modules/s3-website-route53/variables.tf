variable "tags" {
  type    = map(any)
  default = {}
}

resource "null_resource" "check-tags" {
  lifecycle {
    precondition {
      condition     = length(var.tags) != 0 || length(data.aws_default_tags.test.tags) != 0
      error_message = "Tags are required!"
    }
  }
}



variable "domain" {
  type = string
}

variable "domain-zone" {
  type = string
}

variable "vpc-endpoint-name" {
  type = string
}

variable "vpc-name" {
  type = string
}
