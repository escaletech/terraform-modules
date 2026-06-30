variable "family" {
  description = "Nome da tarefa ECS."
  type        = string
}

variable "image" {
  description = "Imagem do container SFTPGo."
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
  description = "CPU alocada para a tarefa ECS."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memória alocada para a tarefa ECS."
  type        = number
  default     = 1024
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

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "arn_attach_additional_policy" {
  description = "Policies IAM adicionais (ex.: S3 scoped)"
  type        = list(string)
  default     = []
}

variable "cpu_architecture" {
  description = "Arquitetura da CPU para a tarefa ECS."
  type        = string
  default     = "X86_64"
}

variable "vpc_id" {
  description = "VPC ID onde o EFS será criado."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets onde o EFS criará os mount targets."
  type        = list(string)
}

variable "ecs_task_sg_id" {
  description = "Security Group ID das tasks ECS para acesso ao EFS."
  type        = string
}

variable "tags" {
  description = "Tags aplicadas ao EFS."
  type        = map(string)
  default     = {}
}

variable "efs_mount_path" {
  description = "Caminho de mount do EFS no container (host keys)."
  type        = string
  default     = "/var/lib/sftpgo"
}

variable "access_point_root_path" {
  description = "Caminho raiz do access point EFS."
  type        = string
  default     = "/sftpgo-data"
}

variable "volume_name" {
  description = "Nome do volume EFS na task definition."
  type        = string
  default     = null
  nullable    = true
}

variable "efs_uid" {
  description = "UID do access point EFS."
  type        = number
  default     = 1000
}

variable "efs_gid" {
  description = "GID do access point EFS."
  type        = number
  default     = 1000
}
