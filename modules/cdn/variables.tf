# Deployment environment
variable "environment" {
  type    = string
  default = "staging"
}

# Existing DNS Zone
variable "dns_zone" { type = string }

# Host for endpoint access
variable "host" { type = string }

# Origin host for cloudfront
variable "origin_host" { type = string }

# Map of tags to identify this resource on AWS
variable "tags" {
  type = map
  default = {
    Name        = "add-application-name"
    Owner       = "add-application-owner"
    Environment = "add-environment"
    Repository  = "add-github-repository"
  }
}

# If you want cloudfront to forward cookies
variable "cookies_forward" {
  type    = string
  default = "none"
}

# If cookies_forward is whitelist, specify those here
variable "cookies_whitelisted" {
  type    = list(string)
  default = null
}

# The AWS S3 bucket to store access logs
variable "logging_bucket" { type = string }
