variable "domain" {
  description = "custom domain to api gateway"
  type        = string
}

variable "zone" {
  description = "zone where the domain will be created"
  type        = string
}

variable "create_dns" {
  description = "Whether to create the Route53 DNS record"
  type        = bool
  default     = true
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

variable "api_key_source" {
  description = "API Key Source"
  type        = string
  default     = "HEADER"
}

variable "endpoint_type" {
  description = "API Gateway custom domain endpoint type: EDGE or REGIONAL"
  type        = string
  default     = "EDGE"

  validation {
    condition     = contains(["EDGE", "REGIONAL"], var.endpoint_type)
    error_message = "endpoint_type must be either \"EDGE\" or \"REGIONAL\"."
  }
}

locals {
  domain          = var.domain
  name            = var.name
  certificate_arn = var.certificate_arn
}
