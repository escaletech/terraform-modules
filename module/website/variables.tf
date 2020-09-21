variable "environment" { type = string }
variable "dns_zone" { type = string }
variable "host" { type = string }
variable "origin_host" { type = string }
variable "tags" { type = map }
variable "whitelisted_names" { type = list(string) }
variable "logging_bucket" { type = string }
