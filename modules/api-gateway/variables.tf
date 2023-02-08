variable "domain" {
  description = "custom domain to api gateway"
  type        = string
}

variable "zone" {
  description = "zone where the domain will be created"
  type        = string
}

variable "certificate_arn" {
  type = string
}

variable "private_zone" {
  description = "zone is private"
  type        = bool
  default     = false
}

variable "name" {
  description = "API Gateway's name"
  type        = string
}

variable "certificate_arn" {
  type = string
}

locals {
  domain          = var.domain
  name            = var.name
  certificate_arn = var.certificate_arn
}
