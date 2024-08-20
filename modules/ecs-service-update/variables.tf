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
  default     = null
}
variable "target_group_arn" {
  description = "Target group utilizado pelo load balancer."
  type        = string
  default     = null
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

variable "max_capacity" {
  description = "The maximum capacity of the scalable target."
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "The minimum capacity of the scalable target."
  type        = number
  default     = 1
}

variable "auto_scaling" {
  description = "Flag to enable or disable auto scaling."
  type        = bool
  default     = false
}

variable "memory_target" {
  description = "The amount of memory"
  type        = number
  default     = 80
}

variable "cpu_target" {
  description = "The amount of cpu"
  type        = number
  default     = 60
}

variable "capacity_provider_strategy" {
  description = "Default capacity provider strategy for the ECS cluster"
  type = list(object({
    weight            = number
    capacity_provider = string
  }))
  default = [
    {
      weight            = 2
      capacity_provider = "FARGATE_SPOT"
    },
    {
      weight            = 1
      capacity_provider = "FARGATE"
    }
  ]
}