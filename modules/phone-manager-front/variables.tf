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