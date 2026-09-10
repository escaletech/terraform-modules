# modules/tags

Módulo utilitário que gera o **map canônico de tags** da Escale para ser aplicado a todos os recursos AWS de um stack.

Não cria nenhum recurso — apenas valida os inputs e retorna o map via `output "tags"`.

---

## Uso básico

```hcl
module "tags" {
  source = "../../modules/tags"

  # Obrigatórias
  env              = "production"           # production | staging | homolog
  business_partner = "claro"               # valor livre — cadastrado no banco
  operation        = "broadband-retention" # valor livre — cadastrado no banco
  vertical         = "telecom"             # telecom | finance | health | cross | internal
  team             = "platform"
  repository       = "github.com/escale-ai/infra-claro"
}

# Aplicar via default_tags no provider (propaga a TODOS os recursos)
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = module.tags.tags
  }
}
```

---

## Uso com tags opcionais

```hcl
module "tags" {
  source = "../../modules/tags"

  env              = "staging"
  business_partner = "vivo"
  operation        = "pre-paid-recharge"
  vertical         = "telecom"
  team             = "growth"
  repository       = "github.com/escale-ai/infra-vivo"

  # Opcionais
  product         = "recharge-api"
  cost_center     = "cc-telecom-vivo"
  criticality     = "high"
  data_scope      = "pii"               # pii | sensitive-pii | non-pii
  auto_stop       = "true"              # desliga instâncias fora do horário comercial
  backup          = "daily-7d"          # daily-7d | weekly-30d | monthly-90d | none
  data_classification = "confidential"  # public | internal | confidential
}
```

---

## Tags geradas

### Obrigatórias

| Chave             | Origem                | Valores                                             |
|-------------------|-----------------------|-----------------------------------------------------|
| `env`             | `var.env`             | `production`, `staging`, `homolog`                  |
| `business-partner`| `var.business_partner`| Livre — gerenciado no banco de dados da plataforma  |
| `operation`       | `var.operation`       | Livre — gerenciado no banco de dados da plataforma  |
| `vertical`        | `var.vertical`        | `telecom`, `finance`, `health`, `cross`, `internal` |
| `team`            | `var.team`            | Livre                                               |
| `repository`      | `var.repository`      | URL do repositório IaC                              |
| `managed-by`      | Fixo                  | `terraform`                                         |

### Opcionais (omitidas quando `null`)

| Chave               | Valores permitidos                               | Finalidade                        |
|---------------------|--------------------------------------------------|-----------------------------------|
| `product`           | Livre                                            | Nome de produto legível           |
| `cost-center`       | Livre                                            | Centro de custo financeiro        |
| `criticality`       | `critical`, `high`, `medium`, `low`              | SLA e prioridade de incidentes    |
| `data-scope`        | `pii`, `sensitive-pii`, `non-pii`                | Conformidade LGPD                 |
| `auto-stop`         | `true`, `false`                                  | AWS Instance Scheduler            |
| `backup`            | `daily-7d`, `weekly-30d`, `monthly-90d`, `none`  | AWS Backup                        |
| `data-classification`| `public`, `internal`, `confidential`            | Sensibilidade dos dados           |

---

## Override por recurso

```hcl
resource "aws_s3_bucket" "pii_exports" {
  bucket = "escale-pii-exports"

  tags = merge(module.tags.tags, {
    data-scope = "sensitive-pii"   # sobrescreve apenas esta tag
    backup     = "monthly-90d"
  })
}
```

---

## Outputs

| Nome   | Tipo          | Descrição                                          |
|--------|---------------|----------------------------------------------------|
| `tags` | `map(string)` | Map completo de tags, pronto para `default_tags`   |

---

## Requisitos

| Nome      | Versão mínima |
|-----------|---------------|
| terraform | >= 1.5        |
