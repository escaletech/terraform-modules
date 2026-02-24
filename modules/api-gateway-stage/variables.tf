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

variable "hash" {
  description = "Hash to redeploy the stage"
  type        = string
  default     = null
}

variable "create_deployment" {
  description = "Whether this module should create an API Gateway deployment"
  type        = bool
  default     = false
}

variable "base_path" {
  type    = string
  default = null
}

variable "private" {
  type    = bool
  default = false
}

locals {
  name      = var.name
  domain    = var.domain
  variables = var.variables
}

variable "deployment_id" {
  type    = string
  default = null
}

variable "enable_waf_association" {
  description = "Ativa a associacao com um WAF existente de modo opcional"
  type        = bool
  default     = false
}

variable "waf_web_acl_arn" {
  description = "ARN do Web ACL WAF a ser associado sendo obrigatorio se enable waf association for true"
  type        = string
  default     = null
}