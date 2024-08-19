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

variable "capacity_providers" {
  description = "Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT"
  type        = string
  default     = "FARGATE"
}