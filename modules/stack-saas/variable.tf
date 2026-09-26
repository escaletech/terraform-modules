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
  description = "Tags do stack. Esquema recomendado: module.standard_tags.tags (modules/tags), em PascalCase. O esquema legado (owner, partner, business, product) ainda e aceito, mas gera warning no plan e sera removido na v2.0.0."
  type        = map(string)

  validation {
    condition = (
      # esquema legado (case-insensitive, como era aceito antes)
      alltrue([for k in ["owner", "partner", "business", "product"] :
        contains([for t in keys(var.tags) : lower(t)], k)
      ])
      ||
      # esquema canonico gerado por modules/tags
      alltrue([for k in ["Environment", "Partner", "Operation", "Owner", "ManagedBy", "Repository"] :
        contains(keys(var.tags), k)
      ])
    )
    error_message = "tags deve conter o esquema canonico (Environment, Partner, Operation, Owner, ManagedBy, Repository — use module.standard_tags.tags do modulo modules/tags) ou, temporariamente, o esquema legado (owner, partner, business, product)."
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

variable "api_gateway_name" {
  description = "API Gateway REST API name used for Escale routes."
  type        = string
  default     = "api-escale-saas"
}

variable "api_gateway_vpc_link_name" {
  description = "API Gateway VPC Link name used for integrations."
  type        = string
  default     = "vpc-link-api-escale-saas"
}

variable "api_gateway_certificate_domain" {
  description = "ACM certificate domain used for the Escale custom domain."
  type        = string
  default     = "*.saas.xclapi.in"
}

variable "api_gateway_zone_name" {
  description = "Route53 hosted zone name for the Escale custom domain."
  type        = string
  default     = "saas.xclapi.in"
}

variable "stage_name" {
  description = "Stage name for the API Gateway"
  type        = string
  default     = "production"
}