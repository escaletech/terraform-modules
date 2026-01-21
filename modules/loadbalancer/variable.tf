variable "lb_type" {
  description = "Load balancer type to create: alb or nlb."
  type        = string
  default     = "alb"
  validation {
    condition     = contains(["alb", "nlb"], var.lb_type)
    error_message = "lb_type must be one of: alb, nlb."
  }
}

variable "name" {
  description = "Load balancer name."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC id for security groups and target groups. If null, vpc_name is used."
  type        = string
  default     = null
  validation {
    condition     = var.vpc_id != null || var.vpc_name != null
    error_message = "Either vpc_id or vpc_name must be provided."
  }
}

variable "vpc_name" {
  description = "VPC name tag to look up when vpc_id is null."
  type        = string
  default     = null
}

variable "alb_internal" {
  description = "Whether the ALB is internal (private)."
  type        = bool
  default     = false
}

variable "alb_subnet_ids" {
  description = "Subnet ids for the ALB."
  type        = list(string)
  default     = []
  validation {
    condition     = var.lb_type != "alb" || length(var.alb_subnet_ids) > 0
    error_message = "alb_subnet_ids must be provided when lb_type is alb."
  }
}

variable "alb_security_group_ids" {
  description = "Security group ids to attach to the ALB when not creating a new one."
  type        = list(string)
  default     = []
}

variable "alb_create_security_group" {
  description = "Whether to create a security group for the ALB."
  type        = bool
  default     = true
}

variable "alb_ingress_ports" {
  description = "Ingress ports for the ALB security group."
  type        = list(number)
  default     = [80, 443]
}

variable "alb_ingress_cidr_blocks" {
  description = "Ingress CIDR blocks for the ALB security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_egress_cidr_blocks" {
  description = "Egress CIDR blocks for the ALB security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_egress_ipv6_cidr_blocks" {
  description = "Egress IPv6 CIDR blocks for the ALB security group."
  type        = list(string)
  default     = ["::/0"]
}

variable "alb_enable_default_listeners" {
  description = "Whether to create the default HTTP->HTTPS and HTTPS fixed-response listeners for the ALB."
  type        = bool
  default     = true
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener."
  type        = string
  default     = null
  validation {
    condition     = !var.alb_enable_default_listeners || var.alb_certificate_arn != null
    error_message = "alb_certificate_arn must be provided when alb_enable_default_listeners is true."
  }
}

variable "alb_https_fixed_response" {
  description = "Fixed response for the ALB HTTPS listener."
  type = object({
    status_code  = number
    message_body = string
    content_type = string
  })
  default = {
    status_code  = 404
    message_body = "Not Found"
    content_type = "text/plain"
  }
}

variable "nlb_internal" {
  description = "Whether the NLB is internal."
  type        = bool
  default     = true
}

variable "nlb_subnet_ids" {
  description = "Subnet ids for the NLB."
  type        = list(string)
  default     = []
  validation {
    condition     = var.lb_type != "nlb" || length(var.nlb_subnet_ids) > 0
    error_message = "nlb_subnet_ids must be provided when lb_type is nlb."
  }
}

variable "nlb_security_group_ids" {
  description = "Security group ids to attach to the NLB when not creating a new one."
  type        = list(string)
  default     = []
}

variable "nlb_create_security_group" {
  description = "Whether to create a security group for the NLB."
  type        = bool
  default     = true
}

variable "nlb_ingress_ports" {
  description = "Ingress ports for the NLB security group."
  type        = list(number)
  default     = [80, 443]
}

variable "nlb_ingress_cidr_blocks" {
  description = "Ingress CIDR blocks for the NLB security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nlb_additional_ingress_rules" {
  description = "Extra ingress rules for the NLB security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "nlb_egress_cidr_blocks" {
  description = "Egress CIDR blocks for the NLB security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nlb_egress_ipv6_cidr_blocks" {
  description = "Egress IPv6 CIDR blocks for the NLB security group."
  type        = list(string)
  default     = ["::/0"]
}

variable "nlb_enable_cross_zone_load_balancing" {
  description = "Whether cross-zone load balancing is enabled for the NLB."
  type        = bool
  default     = true
}

variable "nlb_listeners" {
  description = "Listeners to create for the NLB."
  type = list(object({
    port             = number
    protocol         = string
    target_group_arn = string
  }))
  default = []
}
