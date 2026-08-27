variable "name" {
  description = "Nome do Web ACL REGIONAL. Padrao alinhado ao plano v1 (um ACL por conta/regiao)."
  type        = string
  default     = "WAF-shared-platform"
}

variable "description" {
  description = "Descricao do Web ACL."
  type        = string
  default     = "Shared regional WAF for public platform REST APIs and opt-in ALB associations. CRS/SQLi/KnownBadInputs in count. Do not use as a global IP allowlist."
}

variable "scope" {
  description = "Escopo WAFv2. API Gateway REST e ALB exigem REGIONAL."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = var.scope == "REGIONAL"
    error_message = "Este modulo e apenas REGIONAL (API Gateway REST / ALB). Nao use CLOUDFRONT."
  }
}

variable "allow_ipv4_cidrs" {
  description = "CIDRs do IP set de allow (prio 0, action allow). Vazio = no-op. Nao usar como allowlist global de servicos publicos."
  type        = list(string)
  default     = []
}

variable "deny_ipv4_cidrs" {
  description = "CIDRs do IP set de deny (prio 5, action block). Vazio = no-op."
  type        = list(string)
  default     = []
}

variable "stage_arns" {
  description = "Mapa estavel de ARNs de stage REST para associar. Vazio no primeiro apply (trafego zero). Chave livre (ex. blocklist-east-2)."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for arn in values(var.stage_arns) : can(regex("^arn:aws:apigateway:", arn))
    ])
    error_message = "stage_arns deve conter ARNs arn:aws:apigateway:.../restapis/{id}/stages/{stage}."
  }
}

variable "alb_arns" {
  description = "Mapa estavel de ARNs de ALB para associar. Vazio no v1 ate o gate do REST west-2. Nao incluir o ALB east-2 (WAF-K2)."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for arn in values(var.alb_arns) : can(regex("^arn:aws:elasticloadbalancing:", arn))
    ])
    error_message = "alb_arns deve conter ARNs de Application Load Balancer."
  }
}

variable "log_group_name" {
  description = "Nome do log group. Prefixo aws-waf-logs- e obrigatorio para logging WAFv2."
  type        = string
  default     = "aws-waf-logs-shared-platform"

  validation {
    condition     = startswith(var.log_group_name, "aws-waf-logs-")
    error_message = "log_group_name deve comecar com aws-waf-logs- (requisito da AWS)."
  }
}

variable "log_retention_in_days" {
  description = "Retencao do log group aws-waf-logs-*. Alinhado ao WAF-K2 (30)."
  type        = number
  default     = 30
}

variable "alarm_blocked_requests_threshold" {
  description = "Soma de BlockedRequests (Rule=ALL) que dispara o alarme. No v1 o block real e so IP Reputation."
  type        = number
  default     = 50
}

variable "alarm_period_seconds" {
  description = "Periodo da metrica do alarme, em segundos."
  type        = number
  default     = 300
}

variable "alarm_evaluation_periods" {
  description = "Periodos consecutivos acima do threshold para alarme."
  type        = number
  default     = 3
}

variable "alarm_actions" {
  description = "ARNs SNS (ou outros) para o alarme. Vazio = alarme so no CloudWatch."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas aos recursos do modulo."
  type        = map(string)
  default     = {}
}
