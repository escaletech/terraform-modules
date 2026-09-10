variable "env" {
  description = "Ambiente de execução do stack."
  type        = string
  validation {
    condition     = contains(["production", "staging", "homolog"], var.env)
    error_message = "env deve ser production, staging ou homolog."
  }
}

variable "business_partner" {
  description = "Identificador do parceiro de negócio. Valor livre — cadastrado no banco de dados da plataforma. Responsabilidade da equipe no momento da implementação."
  type        = string
}

variable "operation" {
  description = "Nome da operação dentro do parceiro. Valor livre — cadastrado no banco de dados da plataforma. Responsabilidade da equipe no momento da implementação."
  type        = string
}

variable "vertical" {
  description = "Vertical de negócio para agrupamento financeiro."
  type        = string
  validation {
    condition     = contains(["telecom", "finance", "health", "cross", "internal"], var.vertical)
    error_message = "vertical deve ser telecom, finance, health, cross ou internal."
  }
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
# Tags opcionais — contexto adicional
# ---------------------------------------------------------------------------

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

variable "criticality" {
  description = "Nível de criticidade para SLA: critical, high, medium, low."
  type        = string
  default     = null
  validation {
    condition     = var.criticality == null || contains(["critical", "high", "medium", "low"], var.criticality)
    error_message = "criticality deve ser critical, high, medium ou low."
  }
}

variable "data_scope" {
  description = "Classificação LGPD: pii (dados pessoais), sensitive-pii (dados sensíveis — saúde, financeiro), non-pii (sem dados pessoais)."
  type        = string
  default     = null
  validation {
    condition     = var.data_scope == null || contains(["pii", "sensitive-pii", "non-pii"], var.data_scope)
    error_message = "data_scope deve ser pii, sensitive-pii ou non-pii."
  }
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

variable "data_classification" {
  description = "Sensibilidade dos dados. Valores: public, internal, confidential."
  type        = string
  default     = null
  validation {
    condition     = var.data_classification == null || contains(["public", "internal", "confidential"], var.data_classification)
    error_message = "data_classification deve ser public, internal ou confidential."
  }
}

variable "extra_tags" {
  description = "Tags adicionais específicas do stack, mescladas ao map final. Sobrescrevem qualquer chave em conflito."
  type        = map(string)
  default     = {}
}
