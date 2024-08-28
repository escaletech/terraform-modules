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

  validation {
    condition = alltrue([
      contains([for k in keys(var.tags) : lower(k)], "owner"),
      contains([for k in keys(var.tags) : lower(k)], "partner"),
      contains([for k in keys(var.tags) : lower(k)], "business"),
      contains([for k in keys(var.tags) : lower(k)], "product")
    ])
    error_message = "Tags 'owner', 'partner', 'business' and 'product' is mandatory."
  }
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

variable "spot_staging" {
  description = "Flag to enable or disable spot instances."
  type        = bool
  default     = false
}

variable "spot" {
  description = "Flag to enable or disable spot instances."
  type        = bool
  default     = false
}

variable "weight_fargate" {
  description = "The weight of the capacity provider strategy"
  type        = number
  default     = 2
}

variable "weight_fargate_spot" {
  description = "The weight of the capacity provider strategy"
  type        = number
  default     = 1
}
