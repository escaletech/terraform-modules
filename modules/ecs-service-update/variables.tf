variable "service_name" {
  description = "Nome do serviço ECS a ser atualizado."
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster ECS."
  type        = string
}

variable "task_definition_arn" {
  description = "ARN da definição de tarefa ECS a ser usada para atualização do serviço."
  type        = string
}

variable "subnets" {
  description = "Lista de subnets onde o serviço ECS será executado."
  type        = list(string)
}

variable "security_groups" {
  description = "Lista de security groups a serem associados com o serviço ECS."
  type        = list(string)
}

variable "tags" {
  description = "Tags para o serviço ECS."
  type        = map(string)
}

variable "container_port" {
  description = "Porta utilizada pelo container."
  type        = number
}
variable "target_group_arn" {
  description = "Target group utilizado pelo load balancer."
  type        = string
}

variable "desire_count" {
  description = "Number of instances of the task definition"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  type    = bool
  default = true
}
