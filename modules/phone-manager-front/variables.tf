variable "app_name" { type = string }
variable "domain" { type = string }
variable "dns_zone_name" { type = string }
variable "subnets" { type = list(any) }
variable "vpc_name" { type = string }
variable "private_zone" {
  type    = bool
  default = false
}

variable "internal_ip" {
  type    = bool
  default = true
}

variable "cache_policy_name" {
  type    = string
  default = "default-disable"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "sg-name" {
  type    = string
  default = null
}

resource "null_resource" "check-tags" {
  lifecycle {
    precondition {
      condition     = length(var.tags) != 0 || length(data.aws_default_tags.escale-default-tags.tags) != 0
      error_message = "Tags are required!"
    }
  }
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = false
}

variable "origin_access_domain" {
  type    = string
  default = null
}

variable "origin_access_control" {
  type    = bool
  default = false
}

variable "s3_redirect_enabled" {
  description = "When true, the S3 website hosting responds with a redirect instead of serving the SPA assets."
  type        = bool
  default     = false
}

variable "s3_redirect_host_name" {
  description = "Hostname that receives the redirect (for example, app.example.com). Required when s3_redirect_enabled is true."
  type        = string
  default     = null
}

variable "s3_redirect_protocol" {
  description = "Protocol used in the redirect response."
  type        = string
  default     = "https"
}

variable "s3_redirect_path" {
  description = "Optional path/key to always redirect to (example: novo-site/index.html). Leave empty to preserve the original path."
  type        = string
  default     = null
}

variable "s3_redirect_http_code" {
  description = "HTTP status code returned when redirecting to a fixed path."
  type        = string
  default     = "301"
}
