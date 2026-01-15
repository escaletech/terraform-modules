variable "name" {
  type        = string
  description = "Base name used for resource tags."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "subnets" {
  type = map(object({
    name    = string
    cidr    = string
    az      = string
    public  = bool
    nat_key = string
  }))
  description = "Subnets definition map. For private subnets, nat_key must reference a public subnet key."

  validation {
    condition = length([
      for k, v in var.subnets : k
      if v.public == false && (
        v.nat_key == "" || !contains([for pk, pv in var.subnets : pk if pv.public], v.nat_key)
      )
    ]) == 0
    error_message = "Each private subnet must set nat_key to an existing public subnet key."
  }
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Whether to enable DNS support in the VPC."
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Whether to enable DNS hostnames in the VPC."
}

variable "bastion_vpc_cidr" {
  type        = string
  default     = null
  description = "Optional CIDR block allowed into private ACLs (e.g., a bastion VPC)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources."
}

variable "create_db_subnet_group" {
  type        = bool
  default     = false
  description = "Whether to create an RDS subnet group from private subnets."
}

variable "db_subnet_group_name" {
  type        = string
  default     = null
  description = "Name for the RDS subnet group when enabled."

  validation {
    condition     = var.create_db_subnet_group ? var.db_subnet_group_name != null && var.db_subnet_group_name != "" : true
    error_message = "db_subnet_group_name must be set when create_db_subnet_group is true."
  }
}
