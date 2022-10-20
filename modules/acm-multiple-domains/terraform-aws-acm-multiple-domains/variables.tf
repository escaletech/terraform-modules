variable "domain" {
  description = "Domain name to authenticate against."
  type        = string
}
variable "name" {
  description = "Name of local DNS record."
  type        = string
}
variable "type" {
  description = "DNS record type."
  type        = string
}
variable "record" {
  description = "Certificate Manager DNS entry."
  type        = string
}
variable "ttl" {
  description = "TTL for DNS record."
  type        = string
}

locals {
  domain          = replace(var.domain, "*.", "")
  name            = var.name
  type            = var.type
  record          = var.record
  ttl             = var.ttl
}
