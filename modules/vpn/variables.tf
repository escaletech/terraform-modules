variable "vpc_id" {
  description = "ID da VPC"
  type        = string
  default     = "vpc-0f486687eb8668eba"
}

variable "route_table_id" {
  description = "Route Table associada às subnets da VPC"
  type        = string
  default     = "rtb-0d2a7d2d06e7c4e62"
}

variable "fortigate_public_ip" {
  description = "IP público do FortiGate"
  type        = string
  default     = "186.225.143.246"
}

variable "fortigate_cidrs" {
  description = "Redes atrás do FortiGate"
  type        = list(string)
  default = [
    "10.29.0.0/16",
    "10.212.0.0/16",
    "172.29.0.0/16",
    "10.26.0.0/16"
  ]
}

variable "aws_vpc_cidr" {
  description = "CIDR da VPC AWS"
  type        = string
  default     = "172.18.0.0/16"
}
