variable "name" {
  description = "Stage's name"
  type        = string
}

variable "gateway_api" {
  description = "API Gateway's name"
  type        = string
}

variable "domain" {
  description = "domain"
  type        = string
}

variable "variables" {
  type    = map(string)
  default = {}
}

locals {
  name      = var.name
  domain    = var.domain
  variables = var.variables
}
