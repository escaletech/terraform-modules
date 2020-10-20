variable "environment" { type = string }
variable "dns_zone" { type = string }
variable "host" { type = string }
variable "origin_host" { type = string }
variable "tags" { type = map }
variable "cookies_forward" {
  type = string
  default = "none"
}
variable "cookies_whitelisted" {
  type = list(string)
  default = null
}
variable "logging_bucket" { type = string }
