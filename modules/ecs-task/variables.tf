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