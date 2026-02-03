variable "service_name" {
  description = "Nome do serviço/cliente (ex.: n8n-cliente-abc, n8n-staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde criar o EFS"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas para criar Mount Targets (mínimo 1, ideal 2+)"
  type        = list(string)
}

variable "ecs_task_security_group_ids" {
  description = "Lista de Security Groups das tasks ECS que vão acessar o EFS"
  type        = list(string)
}

variable "tags" {
  description = "Tags para todos os recursos"
  type        = map(string)
  default     = {}
}

variable "performance_mode" {
  type    = string
  default = "generalPurpose"
}

variable "throughput_mode" {
  type    = string
  default = "bursting"
}

variable "transition_to_ia" {
  type    = string
  default = "AFTER_30_DAYS"
}

variable "uid" {
  type    = number
  default = 1000
}

variable "gid" {
  type    = number
  default = 1000
}

variable "root_permissions" {
  type    = string
  default = "0755"
}