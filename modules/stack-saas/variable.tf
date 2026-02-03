locals {
  s3_name = var.s3_name != "" ? var.s3_name : "${var.client_name}-saas"
  name_prefix = var.name_prefix != "" ? var.name_prefix : "platform-conversational-${var.client_name}"
  key_name = var.key_name != "" ? var.key_name : "platform-conversational"


  applications = [
    "${var.client_name}-evolutionWebhook",
    "${var.client_name}-chatwootMedia",
    "${var.client_name}-chat",
    "${var.client_name}-evolution",
    "${var.client_name}-editor",
    "${var.client_name}-viewer"
  ]

}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ami" {
  description = "AMI"
  type        = string
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

variable "route53_id" {
  description = "Route53 Zone ID"
  type        = string
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

variable "containers_name" {
  description = "Container names"
  type        = list(string)
  default     = ["chatwoot", "sidekiq", "typebot-builder", "typebot-viewer", "evolution"]
}


variable "listener_source_ips" {
  description = "Override source IPs per application for ALB listener rules"
  type        = map(list(string))
  default     = {}
}
