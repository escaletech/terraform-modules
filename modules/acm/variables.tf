variable "dns_zone" {
  type = string
}

variable "certificate_host" {
  type = string
}

variable "private_zone" {
  type    = bool
  default = false
}
