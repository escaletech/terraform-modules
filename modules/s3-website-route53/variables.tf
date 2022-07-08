variable "tags" { type = map(any) }
variable "domain" {
  type = string
}

variable "domain-zone" {
  type  = string
}

variable "dns_zone_id" {
  type = string
}

variable "endpoint-name" {
  type = string
}

variable "vpc-endpoint" {
  type = string
}

variable "vpc-name" {
  type = string
}
