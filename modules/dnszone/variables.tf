variable "dnszone" {
  description = "The FQND of the domain"
  type        = string
}

variable "tags" {
  description = "The FQND of the domain"
  type        = map(any)
}

variable "vpc_id" {
  description = "The ID of the VPC where the DNS zone will be created (deprecated; use vpc_associations)"
  type        = map(any)
}

variable "private" {
  description = "Whether the zone is private and should be associated with VPCs"
  type        = bool
  default     = false
}

variable "vpc_associations" {
  description = "List of VPC associations for the private zone (id + region)"
  type = list(object({
    vpc_id     = string
    vpc_region = string
  }))
  default = []

  validation {
    condition     = (!var.private) || (length(var.vpc_associations) > 0)
    error_message = "When private=true, at least one VPC association must be provided in vpc_associations."
  }
}
