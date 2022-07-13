variable "subnets" { type = list(any) }
variable "tags" { type = map(any) }
variable "vpc_name" { type = string }
variable "default_domain" { type = string }

variable "additional_domains" {
  type = list(string)
}
