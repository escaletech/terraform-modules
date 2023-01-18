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

locals {
  name   = var.name
  domain = var.domain
}