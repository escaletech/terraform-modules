variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

variable "dns_zone" {
  description = "DNS Zone for subdomain creation"
  type        = string
}

variable "host" {
  description = "Host for endpoint access"
  type        = string
}

variable "origin_host" {
  description = "Origin host for cloudfront"
  type        = string
}

variable "tags" {
  description = "Map of tags to identify this resource on AWS"
  type        = map
  default = {
    Name        = "add-application-name"
    Owner       = "add-application-owner"
    Environment = "add-environment"
    Repository  = "add-github-repository"
  }
}

variable "cookies_forward" {
  description = "If you want cloudfront to forward cookies"
  type        = string
  default     = "none"
}

variable "cookies_whitelisted" {
  description = "If cookies_forward is whitelist, specify those here"
  type        = list(string)
  default     = null
}

variable "logging_bucket" {
  description = "AWS S3 bucket to store access logs"
  type        = string
}
