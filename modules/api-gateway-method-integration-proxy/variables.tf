variable "api_gateway_id" {
  description = "API Gateway's ID"
  type        = string
}

variable "resource_id" {
  description = "Resource's ID"
  type        = string
}

variable "method" {
  description = "Method"
  type        = string
  default     = "ANY"
}

variable "authorization" {
  description = "Authorization"
  type        = string
  default     = "NONE"
}

variable "authorizer_id" {
  description = "Authorizer's ID"
  type        = string
  default     = null
}

variable "uri_origin" {
  description = "URI Origin"
  type        = string
}

variable "vpc_link_id" {
  description = "VPC Link's ID"
  type        = string
}

variable "request_parameters_method" {
  description = "Method's Request Parameters"
  type        = map(any)
  default = {
    "method.request.path.proxy" = true
  }
}

variable "cache_key_parameters" {
  description = "Cache Key Parameters"
  type        = list(string)
  default = [
    "method.request.path.proxy"
  ]
}

variable "request_parameters_integration" {
  description = "Request Parameters"
  type        = map(any)
  default = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}