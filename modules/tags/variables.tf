# ---------------------------------------------------------------------------
# Tags obrigatórias — sempre presentes no map final
# ---------------------------------------------------------------------------

variable "environment" {
  description = "Ambiente de execução do stack."
  type        = string
  validation {
    condition     = contains(["production", "staging", "homolog"], var.environment)
    error_message = "environment deve ser production, staging ou homolog."
  }
}

variable "partner" {
  description = "Identificador do parceiro de negócio. Valor livre — cadastrado no banco de dados da plataforma. Responsabilidade da equipe no momento da implementação."
  type        = string
}

variable "operation" {
  description = "Nome da operação dentro do parceiro. Valor livre — cadastrado no banco de dados da plataforma. Responsabilidade da equipe no momento da implementação."
  type        = string
}

variable "team" {
  description = "Time responsável pelo stack (owner)."
  type        = string
}

variable "repository" {
  description = "URL do repositório GitHub que contém o código IaC deste stack."
  type        = string
}

# ---------------------------------------------------------------------------
# Tags obrigatórias em produção — opcionais nos demais ambientes
# ---------------------------------------------------------------------------

variable "criticality" {
  description = "Nível de criticidade para SLA. Obrigatória quando environment = production."
  type        = string
  default     = null

  validation {
    condition     = var.criticality == null || contains(["critical", "high", "medium", "low"], var.criticality)
    error_message = "criticality deve ser critical, high, medium ou low."
  }

  validation {
    condition     = var.environment != "production" || var.criticality != null
    error_message = "criticality é obrigatória quando environment = production."
  }
}

variable "data_classification" {
  description = "Sensibilidade dos dados. Obrigatória quando environment = production."
  type        = string
  default     = null

  validation {
    condition     = var.data_classification == null || contains(["public", "internal", "confidential"], var.data_classification)
    error_message = "data_classification deve ser public, internal ou confidential."
  }

  validation {
    condition     = var.environment != "production" || var.data_classification != null
    error_message = "data_classification é obrigatória quando environment = production."
  }
}

# ---------------------------------------------------------------------------
# Tags opcionais — contexto adicional
# ---------------------------------------------------------------------------

variable "vertical" {
  description = "Vertical de negócio para agrupamento financeiro."
  type        = string
  default     = null
  validation {
    condition     = var.vertical == null || contains(["telecom", "finance", "health", "cross", "internal"], var.vertical)
    error_message = "vertical deve ser telecom, finance, health, cross ou internal."
  }
}

variable "product" {
  description = "Nome de produto legível. Ex: whatsapp-tracking, lead-distribution."
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Centro de custo financeiro. Ex: cc-telecom-claro."
  type        = string
  default     = null
}

variable "auto_stop" {
  description = "Habilita desligamento automático fora do horário comercial via AWS Instance Scheduler. Use em homolog e staging para redução de custo."
  type        = string
  default     = null
  validation {
    condition     = var.auto_stop == null || contains(["true", "false"], var.auto_stop)
    error_message = "auto_stop deve ser 'true' ou 'false'."
  }
}

variable "backup" {
  description = "Política de backup via AWS Backup: daily-7d, weekly-30d, monthly-90d, none."
  type        = string
  default     = null
  validation {
    condition     = var.backup == null || contains(["daily-7d", "weekly-30d", "monthly-90d", "none"], var.backup)
    error_message = "backup deve ser daily-7d, weekly-30d, monthly-90d ou none."
  }
}

variable "extra_tags" {
  description = "Tags adicionais específicas do stack, mescladas ao map final. Sobrescrevem qualquer chave em conflito."
  type        = map(string)
  default     = {}
}
