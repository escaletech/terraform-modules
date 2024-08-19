variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "region" {
  description = "Região da AWS onde o cluster ECS será criado"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags para o cluster ECS"
  type        = map(string)
}

variable "enable_container_insights" {
  description = "Habilitar ou desabilitar o Container Insights"
  type        = string
  default     = "disabled"
}

variable "default_capacity_provider_strategy" {
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