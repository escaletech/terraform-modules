variable "subnets" { type = list(any) }
variable "tags" { type = map(any) }
variable "vpc_name" { type = string }


variable "domains" {
  type = list(string)
}
