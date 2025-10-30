variable "family" {
  description = "Nome da tarefa ECS."
  type        = string
}

variable "image" {
  description = "A imagem do container da tarefa ECS."
  type        = string
}

variable "environment-variables" {
  description = "Variáveis de ambiente da tarefa ECS."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cpu" {
  description = "A quantidade de CPU alocada para a tarefa ECS."
  type        = number
  default     = 256
}

variable "memory" {
  description = "A quantidade de memória alocada para a tarefa ECS."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Porta mapeada no container."
  type        = number
  default     = null
}

variable "port_mappings" {
  type = list(object({
    container_port = number
    host_port      = optional(number)
    protocol       = optional(string)
    app_protocol   = optional(string)
    name           = optional(string)
  }))
  default = null
}


variable "protocol" {
  description = "protocolo de rede utilizado."
  type        = string
  default     = "tcp"
}

variable "app_protocol" {
  description = "protocolo utilizado."
  type        = string
  default     = "http"
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "arn_attach_additional_policy" {
  description = "List value to attach additional policy"
  type        = list(string)
  default     = []
}

variable "cpu_architecture" {
  description = "Arquitetura da CPU para a tarefa ECS."
  type        = string
  default     = "X86_64"
}

# variable "retention_in_days" {
#   description = "Quantidade de dias para retenção de logs."
#   type        = number
#   default     = 14
# }
