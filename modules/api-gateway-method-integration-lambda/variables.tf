variable "api_gateway" {
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

variable "lambda_arn" {
  description = "Lambda's ARN"
  type        = string
  
}

variable "response_parameters" {
  description = "Response Parameters"
  type        = map(any)
  default = {
    "application/json" = "LambdaResponseModel"
  }
  
}