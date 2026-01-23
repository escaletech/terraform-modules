variable "zone" {
  description = "zone where the domain will be created"
  type        = string
}

variable "private_zone" {
  description = "zone is private"
  type        = bool
  default     = true
}

variable "name" {
  description = "API Gateway's name"
  type        = string
}

variable "domain" {
  description = "custom domain to api gateway"
  type        = string
}

variable "certificate_arn" {
  type = string
}

variable "vpc_endpoint_ids" {
  description = "VPC ENDPOINT IDs"
  type        = list(string)
}

variable "type_endpoint" {
  description = ""
  type = string
  default = "null"
}

locals {
  name            = var.name
  domain          = var.domain
  certificate_arn = var.certificate_arn  
}
