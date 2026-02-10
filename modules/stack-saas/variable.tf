locals {
  s3_name     = var.s3_name != "" ? var.s3_name : "${var.client_name}-saas"
  name_prefix = var.name_prefix != "" ? var.name_prefix : "platform-conversational-${var.client_name}"
  iam_prefix  = var.role_prefix != "" ? var.role_prefix : local.name_prefix
  key_name    = var.key_name != "" ? var.key_name : "platform-conversational"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ami" {
  description = "AMI"
  type        = string
  default     = "ami-0be5a830e851483f9" ## Amazon Linux 2023
}

variable "tags" {
  description = "Tags para o serviço ECS."
  type        = map(string)

  validation {
    condition = alltrue([
      contains([for k in keys(var.tags) : lower(k)], "owner"),
      contains([for k in keys(var.tags) : lower(k)], "partner"),
      contains([for k in keys(var.tags) : lower(k)], "business"),
      contains([for k in keys(var.tags) : lower(k)], "product")
    ])
    error_message = "Tags 'owner', 'partner', 'business' and 'product' is mandatory."
  }
}

variable "client_name" {
  description = "Client name"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix"
  type        = string
  default     = ""
}

variable "role_prefix" {
  description = "Prefixo para nomes IAM (role/policies/profile)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Key name"
  type        = string
  default     = ""
}


variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs where resources will be created"
  type        = list(string)
}

variable "ipv4_cidr_blocks_allowed" {
  description = "List of IPv4 CIDR blocks allowed to access the instance"
  type        = list(string)
}

variable "ports_ingress_allowed" {
  description = "List of ports allowed to access the instance"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "s3_name" {
  description = "S3 Bucket name"
  type        = string
  default     = ""
}

variable "create_s3" {
  description = "Create S3 bucket and attach policy"
  type        = bool
  default     = true
}

variable "enable_api_gateway" {
  description = "Create API"
  type        = bool
  default     = false
}