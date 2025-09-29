locals {
  
  applications = [
    "${var.client_name}-evolutionWebhook",
    "${var.client_name}-chatwootMedia",
    "${var.client_name}-chat",
    "${var.client_name}-evolution",
    "${var.client_name}-editor",
    "${var.client_name}-viewer"
  ]

  ingress = {
    "${var.client_name}-chat" = {
      host         = "${var.client_name}-chat.${var.default_host}"
      path_pattern = "*"
      health_check = "/"
      port         = 443
      protocol     = "HTTPS"
    }
    "${var.client_name}-chatwootMedia" = {
      host         = "${var.client_name}-chat.${var.default_host}"
      path_pattern = "/rails/active_storage/*"
      health_check = "/"
      port         = 443
      protocol     = "HTTPS"
    }
    "${var.client_name}-evolution" = {
      host         = "${var.client_name}-evolution.${var.default_host}"
      path_pattern = "*"
      health_check = "/"
      port         = 80
      protocol     = "HTTP"
    }
    "${var.client_name}-evolutionWebhook" = {
      host         = "${var.client_name}-evolution.${var.default_host}"
      path_pattern = "*"
      health_check = "/webhook/*"
      port         = 80
      protocol     = "HTTP"
    }
    "${var.client_name}-editor" = {
      host         = "${var.client_name}-editor.${var.default_host}"
      path_pattern = "*"
      health_check = "/"
      port         = 80
      protocol     = "HTTP"
    }
    "${var.client_name}-viewer" = {
      host         = "${var.client_name}-viewer.${var.default_host}"
      path_pattern = "*"
      health_check = "/"
      port         = 80
      protocol     = "HTTP"
    }
  }
  dns = {
    "${var.client_name}-chat" = {
      host = "${var.dns_chatwoot}"
    }
    "${var.client_name}-evolution" = {
      host = "${var.dns_evolution}"
    }
    "${var.client_name}-editor" = {
      host = "${var.dns_builder}"
    }
    "${var.client_name}-viewer" = {
      host = "${var.dns_bot}"
    }
  }

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
  default     = "platform-conversational-${var.client_name}"
}

variable "key_name" {
  description = "Key name"
  type        = string
}

variable "initial_secret_value" {
  description = "Value initial for the secret start"
  type        = string
  default     = "{\"placeholder\": \"init\"}"
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs where resources will be created"
  type        = list(string)
}

variable "listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "ipv4_cidr_blocks" {
  description = "List of IPv4 CIDR blocks allowed to access the instance"
  type        = list(string)
}

variable "ports_ingress_allowed" {
  description = "List of ports allowed to access the instance"
  type        = list(number)
  default     = [22, 80, 443, 2375]
}

variable "s3_name" {
  description = "S3 Bucket name"
  type        = string
  default     = "${var.client_name}-saas"
}

variable "containers_name" {
  description = "Container names"
  type        = list(string)
  default     = ["chatwoot", "sidekiq", "typebot-builder", "typebot-viewer", "evolution"]
}

variable "default_host" {
  description = "Default host"
  type        = string
}

variable "dns_chatwoot" {
  description = "Create DNS record for Chatwoot"
  type        = string
  default     = "${var.client_name}-chat.${var.default_host}"
}

variable "dns_evolution" {
  description = "Create DNS record for Evolution"
  type        = string
  default     = "${var.client_name}-evolution.${var.default_host}"
}

variable "dns_builder" {
  description = "Create DNS record for Typebot Builder"
  type        = string
  default     = "${var.client_name}-editor.${var.default_host}"
}

variable "dns_bot" {
  description = "Create DNS record for Typebot Viewer"
  type        = string
  default     = "${var.client_name}-viewer.${var.default_host}"
}