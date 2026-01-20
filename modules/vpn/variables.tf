variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "route_table_id" {
  description = "Route Table associada às subnets da VPC"
  type        = string
}

variable "fortigate_public_ip" {
  description = "IP público do FortiGate"
  type        = string
}

variable "fortigate_cidrs" {
  description = "Redes atrás do FortiGate"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
  default     = "vpn"
}

variable "tags" {
  description = "Tags adicionais aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
