variable "zone" {
  description = "zone where the domain will be created"
  type        = string
}

variable "private_zone" {
  description = "zone is private"
  type        = bool
  default     = true
}

variable "name" {
  description = "API Gateway's name"
  type        = string
}

variable "domain" {
  description = "custom domain to api gateway"
  type        = string
}

variable "certificate_arn" {
  type = string
}

variable "vpc_endpoint_ids" {
  description = "VPC ENDPOINT IDs"
  type        = list(string)
  default     = []
}

variable "create_vpc_endpoint" {
  description = "Create VPC Endpoint for API Gateway"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID used when creating the VPC endpoint"
  type        = string
  default     = null
}

variable "vpc_endpoint_subnet_ids" {
  description = "Subnet IDs used when creating the VPC endpoint"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_security_group_ids" {
  description = "Security Group IDs used when creating the VPC endpoint"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_private_dns_enabled" {
  description = "Enable private DNS when creating the VPC endpoint"
  type        = bool
  default     = true
}

variable "vpc_endpoint_service_name" {
  description = "Override VPC endpoint service name (default: regional execute-api)"
  type        = string
  default     = null
}

variable "type_endpoint" {
  description = "Endpoint type for the custom domain (REGIONAL or EDGE)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "EDGE"], var.type_endpoint)
    error_message = "type_endpoint must be REGIONAL or EDGE."
  }
}

variable "create_cors_options" {
  description = "Create OPTIONS method responses for CORS on the specified paths"
  type        = bool
  default     = false
}

variable "create_proxy_resource" {
  description = "Create a /{proxy+} resource when cors_paths includes that path"
  type        = bool
  default     = true
}

variable "cors_paths" {
  description = "API Gateway resource paths that should receive an OPTIONS method for CORS"
  type        = list(string)
  default     = []
}

variable "cors_allowed_origins" {
  description = "Allowed Origin list for CORS preflight responses"
  type        = list(string)
  default     = []
}

locals {
  name            = var.name
  domain          = var.domain
  certificate_arn = var.certificate_arn
  vpc_cidr_block  = var.create_vpc_endpoint ? data.aws_vpc.selected[0].cidr_block : null
  vpc_endpoint_ids_effective = var.create_vpc_endpoint ? [aws_vpc_endpoint.api_gateway_vpc_endpoint[0].id] : var.vpc_endpoint_ids
  vpc_endpoint_security_group_ids_effective = var.create_vpc_endpoint ? concat([aws_security_group.vpc_endpoint[0].id], var.vpc_endpoint_security_group_ids) : var.vpc_endpoint_security_group_ids
  cors_paths_set         = toset(var.cors_paths)
  cors_proxy_path        = "/{proxy+}"
  create_proxy_resource_effective = var.create_proxy_resource && contains(local.cors_paths_set, local.cors_proxy_path)
}
