variable "zone_id" {
  type        = string
  default     = null
  description = "Route 53 zone ID. If null, zone_name must be set."
}

variable "record_name" {
  type        = string
  default     = null
  description = "Route 53 record name (e.g., www.example.com.)."
}

variable "private_zone" {
  type        = bool
  default     = false
  description = "Whether the zone_name lookup is for a private zone."
}

variable "record_type" {
  type        = string
  default     = "A"
  description = "Route 53 record type (e.g., A, CNAME, TXT)."
}

variable "alias_name" {
  type = string
  default = null
  description = "Name ALB / NLB target."
}

variable "alias_zone_id" {
  type = string
  default = null
  description = "ALB Zone ID"
}

variable "records" {
  type        = list(string)
  default     = []
  description = "Record values for non-alias records (e.g., CNAME target)."
}

variable "ttl" {
  type        = number
  default     = null
  description = "TTL (seconds) for non-alias records. Defaults to default_ttl when null."
}

variable "default_ttl" {
  type        = number
  default     = 300
  description = "Default TTL (seconds) for non-alias records when ttl is not set per record."
}

variable "allow_overwrite" {
  type        = bool
  default     = true
  description = "Whether to allow overwriting existing records."
}
