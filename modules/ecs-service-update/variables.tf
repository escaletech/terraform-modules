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

variable "iam_role" {
  description = "(Optional) ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role. If your account has already created the Amazon ECS service-linked role, that role is used by default for your service unless you specify a role here."
  type        = string
  default     = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
}

variable "desire_count" {
  description = "Number of instances of the task definition"
  type        = number
  default     = 1
}
