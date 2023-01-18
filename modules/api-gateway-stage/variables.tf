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

variable "tags" {
  type = map(string)
}

locals {
  name = var.name
  domain = var.domain
}