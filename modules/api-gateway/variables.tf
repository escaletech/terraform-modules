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

variable "api_key_source" {
  description = "API Key Source"
  type        = string
  default     = "HEADER"
}

variable "minimum_compression_size" {
  description = "Minimum response size in bytes to enable gzip compression on the REST API. Default 1024 compresses responses >= 1 KB. Use -1 to compress all eligible responses. Set null to disable compression."
  type        = number
  default     = 1024

  validation {
    condition     = var.minimum_compression_size == null || (var.minimum_compression_size >= -1 && var.minimum_compression_size <= 10485760)
    error_message = "minimum_compression_size must be null, -1, or between 0 and 10485760 (10MB)."
  }
}

locals {
  domain          = var.domain
  name            = var.name
  certificate_arn = var.certificate_arn
}
