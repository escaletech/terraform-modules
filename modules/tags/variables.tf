# ---------------------------------------------------------------------------
# Convenção de chaves
#
# As chaves do map final são geradas em PascalCase (Environment, Partner,
# ManagedBy...) — o padrão já em uso nos stacks da Escale. Chaves em lowercase
# ou kebab-case são rejeitadas pela validação de `extra_tags` e pelos módulos
# consumidores.
#
# Os nomes das *variáveis* seguem snake_case por convenção do Terraform.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Tags obrigatórias — sempre presentes no map final
# ---------------------------------------------------------------------------

variable "environment" {
  description = "Ambiente de execução do stack. Gera a tag Environment."
  type        = string
  validation {
    condition     = contains(["Production", "Staging", "Homolog"], var.environment)
    error_message = "environment deve ser Production, Staging ou Homolog."
  }
}

variable "partner" {
  description = "Identificador do parceiro de negócio. Valor livre — cadastrado no banco de dados da plataforma. Gera a tag Partner."
  type        = string
}

variable "operation" {
  description = "Nome da operação dentro do parceiro. Valor livre — cadastrado no banco de dados da plataforma. Gera a tag Operation."
  type        = string
}

variable "owner" {
  description = "Time responsável pelo stack. Gera a tag Owner."
  type        = string
}

variable "repository" {
  description = "URL do repositório GitHub que contém o código IaC deste stack. Gera a tag Repository."
  type        = string
}

# ---------------------------------------------------------------------------
# Tags obrigatórias em produção — opcionais nos demais ambientes
# ---------------------------------------------------------------------------

variable "criticality" {
  description = "Nível de criticidade para SLA. Obrigatória quando environment = Production. Gera a tag Criticality."
  type        = string
  default     = null

  validation {
    condition     = var.criticality == null || contains(["Critical", "High", "Medium", "Low"], var.criticality)
    error_message = "criticality deve ser Critical, High, Medium ou Low."
  }

  validation {
    condition     = var.environment != "Production" || var.criticality != null
    error_message = "criticality é obrigatória quando environment = Production."
  }
}

variable "data_classification" {
  description = "Sensibilidade dos dados. Obrigatória quando environment = Production. Gera a tag DataClassification."
  type        = string
  default     = null

  validation {
    condition     = var.data_classification == null || contains(["Public", "Internal", "Confidential"], var.data_classification)
    error_message = "data_classification deve ser Public, Internal ou Confidential."
  }

  validation {
    condition     = var.environment != "Production" || var.data_classification != null
    error_message = "data_classification é obrigatória quando environment = Production."
  }
}

# ---------------------------------------------------------------------------
# Tags opcionais — contexto adicional
# ---------------------------------------------------------------------------

variable "vertical" {
  description = "Vertical de negócio para agrupamento financeiro. Gera a tag Vertical."
  type        = string
  default     = null
  validation {
    condition     = var.vertical == null || contains(["Telecom", "Finance", "Health", "Cross", "Internal"], var.vertical)
    error_message = "vertical deve ser Telecom, Finance, Health, Cross ou Internal."
  }
}

variable "product" {
  description = "Nome de produto legível. Gera a tag Product."
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Centro de custo financeiro. Gera a tag CostCenter."
  type        = string
  default     = null
}

variable "auto_stop" {
  description = "Habilita desligamento automático fora do horário comercial via AWS Instance Scheduler. Use em Homolog e Staging para redução de custo. Gera a tag AutoStop."
  type        = string
  default     = null
  validation {
    condition     = var.auto_stop == null || contains(["true", "false"], var.auto_stop)
    error_message = "auto_stop deve ser 'true' ou 'false'."
  }
}

variable "backup" {
  description = "Política de backup via AWS Backup. Gera a tag Backup."
  type        = string
  default     = null
  validation {
    condition     = var.backup == null || contains(["Daily7d", "Weekly30d", "Monthly90d", "None"], var.backup)
    error_message = "backup deve ser Daily7d, Weekly30d, Monthly90d ou None."
  }
}

variable "extra_tags" {
  description = "Tags adicionais específicas do stack, mescladas ao map final. Chaves devem estar em PascalCase. Sobrescrevem qualquer chave em conflito."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.extra_tags) : can(regex("^[A-Z][A-Za-z0-9]*$", k))])
    error_message = "Chaves de extra_tags devem estar em PascalCase, iniciando com maiúscula e sem separadores. Ex: BusinessUnit — não business-unit, business_unit ou businessUnit."
  }
}
