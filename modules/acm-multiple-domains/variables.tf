variable "certificate_arn" {
  description = "Certificate ARN."
}
variable "domain" {
  description = "Domain name to authenticate against."
}
variable "name" {
  description = "Name of local DNS record."
}
variable "type" {
  description = "DNS record type."
}
variable "record" {
  description = "Certificate Manager DNS entry."
}
variable "ttl" {
  description = "TTL for DNS record."
}
variable "certificate_host" {
  type = string
}
variable "alternative_domain" {
  type = list(string)
}

locals {
  certificate_arn = var.certificate_arn
  domain          = replace(var.domain, "*.", "")
  name            = var.name
  type            = var.type
  record          = var.record
  ttl             = 60
}
