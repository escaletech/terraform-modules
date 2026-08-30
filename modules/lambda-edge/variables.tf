variable "tags" { type = map(any) }

variable "lambda_file" {
  type        = string
  description = "Interceptor file"

  validation {
    condition     = length(var.lambda_file) > 0
    error_message = "The interceptor file is required."
  }
}

variable "lambda_edge_role_name" {
  type        = string
  description = "Lambda edge role name"

  validation {
    condition     = length(var.lambda_edge_role_name) > 0
    error_message = "The lambda_edge_role_name is required."
  }
}

variable "lambda_function_name" {
  type        = string
  description = "lambda function name"

  validation {
    condition     = length(var.lambda_function_name) > 0
    error_message = "The lambda_function_name is required."
  }
}

variable "lambda_tracing_mode" {
  type        = string
  description = "AWS Lambda X-Ray tracing mode. PassThrough (default) propagates trace context without creating segments — recommended for Lambda@Edge to minimize X-Ray cost. Active creates sampled trace segments (1 req/s + 5%). Off disables tracing entirely."
  default     = "PassThrough"

  validation {
    condition     = contains(["Active", "PassThrough", "Off"], var.lambda_tracing_mode)
    error_message = "The lambda_tracing_mode must be Active, PassThrough, or Off."
  }
}
