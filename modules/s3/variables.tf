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
  default     = "public-read"
}

variable "s3_policy_document" {
  description = "A política de acesso para o bucket S3. Se não fornecida, será criada uma política padrão."
  type = object({
    statement = list(object({
      actions   = list(string)
      resources = list(string)
      effect    = string
    }))
  })
  default = {
    statement = [
      {
        actions   = ["s3:GetObject"]
        resources = ["arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}/*"]
        effect    = "Allow"
      }
    ]
  }
}