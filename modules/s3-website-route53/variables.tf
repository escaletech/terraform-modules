variable "tags" { type = map(any) }
variable "domain" {
  type = string
}

variable "domain-zone" {
  type = string
}

variable "vpc-endpoint-name" {
  type = string
}

variable "vpc-name" {
  type = string
}
