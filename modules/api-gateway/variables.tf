variable "domain" {
  description = "custom domain to api gateway"
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "zone" {
  description = "zone where the domain will be created"
  type        = string
}

variable "name" {
  description = "API Gateway's name"
  type        = string
}

locals {
  domain = var.domain
  tags   = var.tags
  name   = var.name
}