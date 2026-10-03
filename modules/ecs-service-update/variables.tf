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
    condition = (
      # esquema legado (case-insensitive, como era aceito antes)
      alltrue([for k in ["owner", "partner", "business", "product"] :
        contains([for t in keys(var.tags) : lower(t)], k)
      ])
      ||
      # esquema canonico gerado por modules/tags
      alltrue([for k in ["Environment", "Partner", "Operation", "Owner", "ManagedBy", "Repository"] :
        contains(keys(var.tags), k)
      ])
    )
    error_message = "tags deve conter o esquema canonico (Environment, Partner, Operation, Owner, ManagedBy, Repository — use module.standard_tags.tags do modulo modules/tags) ou o esquema legado (owner, partner, business, product)."
  }
}

variable "container_port" {
  description = "Porta utilizada pelo container."
  type        = number
  default     = null
}

variable "load_balancers" {
  type = list(object({
    container_name   = optional(string)
    container_port   = number
    target_group_arn = string
  }))
  default = null
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

variable "propagate_tags" {
  description = "Propaga tags para as tasks (SERVICE ou TASK_DEFINITION). Necessario para alocar custo de Fargate por tag. null mantem o comportamento atual."
  type        = string
  default     = null

  validation {
    condition     = var.propagate_tags == null || contains(["SERVICE", "TASK_DEFINITION", "NONE"], coalesce(var.propagate_tags, "NONE"))
    error_message = "propagate_tags deve ser SERVICE, TASK_DEFINITION, NONE ou null."
  }
}
