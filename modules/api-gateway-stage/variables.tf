variable "name" {
  description = "Stage's name"
  type        = string
}

variable "gateway_api" {
  description = "API Gateway's name"
  type        = string
}

variable "gateway_api_id" {
  description = "API Gateway's id"
  type        = string
  default     = null
}

variable "domain" {
  description = "domain"
  type        = string
}

variable "variables" {
  type    = map(string)
  default = {}
}

# variable "hash" {
#   description = "Hash to redeploy the stage"
#   type    = string
# }

variable "private" {
  type    = bool
  default = false
}

locals {
  name      = var.name
  domain    = var.domain
  variables = var.variables
}
