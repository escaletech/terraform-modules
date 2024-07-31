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

variable "request_models" {
  description = "Method's Request Models"
  type        = map(any)
  default = {
   "application/json" = "OperationRequired"
  }
}

variable "request_parameters_integration" {
  description = "Request Parameters"
  type        = map(any)
  default = {
    "method.request.header.Instance" = true
  }
}

variable "function_name" {
  description = "Lambda's Function Name"
  type        = string
}

variable "source_arn" {
  description = "Source ARN"
  type        = string
}