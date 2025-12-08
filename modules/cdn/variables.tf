variable "dns_zone" { type = string }
variable "host" { type = string }
variable "origin_host" { type = string }
variable "tags" { type = map(any) }
variable "origin_protocol_policy" {
  type    = string
  default = "http-only"
}

variable "web_acl_id" {
  type    = string
  default = null
}

variable "ttl" {
  type    = number
  default = 60
}

variable "alias_main" {
  type    = string
  default = null
}

variable "origin_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.2"]
}

variable "origin_id" {
  description = "The ID for the origin with CloudFront"
  type        = string
  default     = null
}

variable "allow_overwrite" {
  type    = bool
  default = false
}

variable "cache_policy_name" {
  type    = string
  default = "default-eks"
}

variable "origin_request_policy_id" {
  type    = string
  default = null
}

variable "functions" {
  type = list(object({
    event_type = string
    arn        = string
  }))
  default = []
}


variable "lambda_functions" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  default = []
}
variable "bucket_logs_name" {
  type    = string
  default = null
}
variable "custom_cname" {
  type        = list(string)
  default     = []
  description = "When the website endpoint domain is outside our control and we need a CNAME from our host to this outside domain. All other resources are still created based on host, only cloudfront will point itself to this custom domain."
}

variable "dynamic_origins" {
  type = list(object({
    host                   = string
    origin_protocol_policy = string
  }))
  default     = []
  description = "When the website needs more than one custom origins"
}

variable "dynamic_behavior" {
  type = list(object({
    path_pattern             = string
    allowed_methods          = list(string)
    cached_methods           = list(string)
    target_origin_id         = string
    compress                 = bool
    viewer_protocol_policy   = string
    cache_policy_id          = string
    origin_request_policy_id = string
    lambda_function_association = list(object({
      event_type   = string
      lambda_arn   = string
      include_body = bool
    }))
    function_association = list(object({
      event_type   = string
      function_arn = string
    }))
  }))
  default = []
}

variable "additional_error_responses" {
  description = "Includes new custom errors responses"
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
  default = []
}

variable "certificate_name" {
  type    = string
  default = null
}

variable "certificate_enable" {
  type    = bool
  default = null
}

variable "certificate_arn" {
  type    = string
  default = null
}