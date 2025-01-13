variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "website_static" {
  description = "The hostname to redirect all requests to"
  type        = bool
  default     = false
}

variable "website_hostname" {
  description = "The hostname to redirect all requests to"
  type        = string
  default     = ""
}

variable "website_protocol" {
  description = "The protocol to redirect all requests to"
  type        = string
  default     = "https"
}

variable "website_acl" {
  description = "The ACL to apply to the S3 bucket"
  type        = string
  default     = null
}

variable "website_index_document" {
  description = "The index document for the S3 bucket"
  type        = string
  default     = null
}

variable "website_error_document" {
  description = "value of the error document for the S3 bucket"
  type        = string
  default     = null
}

variable "s3_policy_document" {
  type = object({
    statement = list(object({
      sid       = string
      actions   = list(string)
      resources = list(string)
      effect    = string
      principals = object({
        type        = string
        identifiers = list(string)
      })
    }))
  })
  default = null
}

variable "grantee_id" {
  description = "The ID of the AWS account to grant access to"
  type        = string
  default     = null
}

variable "grantee_type" {
  description = "The type of grantee to grant access to"
  type        = string
  default     = "CanonicalUser"
}

variable "grantee_display_name" {
  description = "The display name of the grantee to grant access to"
  type        = string
  default     = null
}

variable "grant_permission" {
  description = "The permission to grant to the grantee"
  type        = string
  default     = "READ"
}

variable "owner_id" {
  description = "The ID of the AWS account that owns the bucket"
  type        = string
  default     = null
}

variable "redirect" {
  description = "Whether to redirect all requests to the website hostname"
  type        = bool
  default     = false 
}

variable "index_document" {
  description = "Whether to set an index document for the S3 bucket"
  type        = bool
  default     = false
}

variable "error_document" {
  description = "Whether to set an error document for the S3 bucket"
  type        = bool
  default     = false
}