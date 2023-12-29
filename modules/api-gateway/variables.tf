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

variable "private" {
  description = "API Gateway's private"
  type        = bool
  default     = false
}

variable "vpc_ids" {
  description = "VPC IDs"
  type        = list(string)
  default     = []
}

locals {
  domain          = var.domain
  name            = var.name
  certificate_arn = var.certificate_arn
}
