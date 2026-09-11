# modules/tags

Módulo utilitário que gera o **map canônico de tags** da Escale para ser aplicado a todos os recursos AWS de um stack.

Não cria nenhum recurso — apenas valida os inputs e retorna o map via `output "tags"`.

---

## Uso básico

```hcl
module "standard_tags" {
  source = "../../modules/tags"

  # Obrigatórias
  environment = "production"           # production | staging | homolog
  partner     = "claro"                # valor livre — cadastrado no banco
  operation   = "broadband-retention"  # valor livre — cadastrado no banco
  team        = "platform"
  repository  = "github.com/escale-ai/infra-claro"

  # Obrigatórias quando environment = "production"
  criticality         = "high"          # critical | high | medium | low
  data_classification = "confidential"  # public | internal | confidential
}

# Aplicar via default_tags no provider (propaga a TODOS os recursos)
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = module.standard_tags.tags
  }
}
```

---

## Uso com tags opcionais

```hcl
module "standard_tags" {
  source = "../../modules/tags"

  environment      = "staging"
  partner          = "vivo"
  operation        = "pre-paid-recharge"
  vertical         = "telecom"
  team             = "growth"
  repository       = "github.com/escale-ai/infra-vivo"

  # Opcionais
  product         = "recharge-api"
  cost_center     = "cc-telecom-vivo"
  criticality     = "high"
  auto_stop       = "true"              # desliga instâncias fora do horário comercial
  backup          = "daily-7d"          # daily-7d | weekly-30d | monthly-90d | none
  data_classification = "confidential"  # public | internal | confidential
}
```

---

## Tags geradas

### Obrigatórias

| Chave         | Origem            | Valores                                            |
|---------------|-------------------|----------------------------------------------------|
| `environment` | `var.environment` | `production`, `staging`, `homolog`                 |
| `partner`     | `var.partner`     | Livre — gerenciado no banco de dados da plataforma |
| `operation`   | `var.operation`   | Livre — gerenciado no banco de dados da plataforma |
| `team`        | `var.team`        | Livre                                              |
| `repository`  | `var.repository`  | URL do repositório IaC                             |
| `managed-by`  | Fixo              | `terraform`                                        |

### Obrigatórias em produção

Opcionais em `staging` e `homolog`; quando `environment = "production"`, a ausência
falha no `terraform plan`.

| Chave                | Origem                    | Valores                                |
|----------------------|---------------------------|----------------------------------------|
| `criticality`        | `var.criticality`         | `critical`, `high`, `medium`, `low`    |
| `data-classification`| `var.data_classification` | `public`, `internal`, `confidential`   |

### Opcionais (omitidas quando `null`)

| Chave         | Valores permitidos                              | Finalidade                     |
|---------------|-------------------------------------------------|--------------------------------|
| `vertical`    | `telecom`, `finance`, `health`, `cross`, `internal` | Agrupamento financeiro     |
| `product`     | Livre                                           | Nome de produto legível        |
| `cost-center` | Livre                                           | Centro de custo financeiro     |
| `auto-stop`   | `true`, `false`                                 | AWS Instance Scheduler         |
| `backup`      | `daily-7d`, `weekly-30d`, `monthly-90d`, `none` | AWS Backup                     |

---

## Override por recurso

```hcl
resource "aws_s3_bucket" "pii_exports" {
  bucket = "escale-pii-exports"

  tags = merge(module.standard_tags.tags, {
    data-classification = "confidential"  # sobrescreve apenas esta tag
    backup              = "monthly-90d"
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
