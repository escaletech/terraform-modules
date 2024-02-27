variable "zone" {
  description = "zone where the domain will be created"
  type        = string
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

variable "vpc_endpoint_ids" {
  description = "VPC ENDPOINT IDs"
  type        = list(string)
}

locals {
  name = var.name
}
