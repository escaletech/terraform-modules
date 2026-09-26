# modules/tags

Módulo utilitário que gera o **map canônico de tags** da Escale para ser aplicado a todos os recursos AWS de um stack.

Não cria nenhum recurso — apenas valida os inputs e retorna o map via `output "tags"`.

---

## Convenção de chaves: PascalCase

As chaves do map são geradas em **PascalCase** (`Environment`, `Partner`, `ManagedBy`), que é o padrão já em uso nos stacks da Escale. Chaves de tag na AWS são *case-sensitive*: `Partner` e `partner` são tags diferentes no Cost Explorer.

Por isso o módulo **rejeita** chaves fora do padrão em `extra_tags`, e os módulos consumidores rejeitam maps com chaves em lowercase, kebab-case ou snake_case.

Os nomes das **variáveis** seguem `snake_case`, por convenção do Terraform. Só as chaves geradas são PascalCase.

---

## Uso básico

```hcl
module "standard_tags" {
  source = "../../modules/tags"

  # Obrigatórias
  environment = "Production"            # Production | Staging | Homolog
  partner     = "claro"                 # valor livre — cadastrado no banco
  operation   = "broadband-retention"   # valor livre — cadastrado no banco
  owner       = "Infra Cloud Team"
  repository  = "https://github.com/escaletech/infra-claro"

  # Obrigatórias quando environment = "Production"
  criticality         = "High"          # Critical | High | Medium | Low
  data_classification = "Confidential"  # Public | Internal | Confidential
}

# Aplicar via default_tags no provider (propaga a TODOS os recursos)
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = module.standard_tags.tags
  }
}
```

Resultado:

```hcl
{
  Environment        = "Production"
  Partner            = "claro"
  Operation          = "broadband-retention"
  Owner              = "Infra Cloud Team"
  ManagedBy          = "Terraform"
  Repository         = "https://github.com/escaletech/infra-claro"
  Criticality        = "High"
  DataClassification = "Confidential"
}
```

---

## Uso com tags opcionais

```hcl
module "standard_tags" {
  source = "../../modules/tags"

  environment = "Staging"
  partner     = "vivo"
  operation   = "pre-paid-recharge"
  owner       = "Growth Team"
  repository  = "https://github.com/escaletech/infra-vivo"

  # Opcionais
  vertical    = "Telecom"
  product     = "recharge-api"
  cost_center = "cc-telecom-vivo"
  auto_stop   = "true"
  backup      = "Weekly30d"
}
```

---

## Tags geradas

### Obrigatórias

| Chave         | Origem            | Valores                                            |
|---------------|-------------------|----------------------------------------------------|
| `Environment` | `var.environment` | `Production`, `Staging`, `Homolog`                 |
| `Partner`     | `var.partner`     | Livre — gerenciado no banco de dados da plataforma |
| `Operation`   | `var.operation`   | Livre — gerenciado no banco de dados da plataforma |
| `Owner`       | `var.owner`       | Livre — time responsável pelo stack                |
| `Repository`  | `var.repository`  | URL do repositório IaC                             |
| `ManagedBy`   | Fixo              | `Terraform`                                        |

### Obrigatórias em produção

Opcionais em `Staging` e `Homolog`; quando `environment = "Production"`, a ausência falha no `terraform plan`.

| Chave                | Origem                    | Valores                              |
|----------------------|---------------------------|--------------------------------------|
| `Criticality`        | `var.criticality`         | `Critical`, `High`, `Medium`, `Low`  |
| `DataClassification` | `var.data_classification` | `Public`, `Internal`, `Confidential` |

### Opcionais (omitidas quando `null`)

| Chave        | Valores permitidos                                  | Finalidade                 |
|--------------|-----------------------------------------------------|----------------------------|
| `Vertical`   | `Telecom`, `Finance`, `Health`, `Cross`, `Internal` | Agrupamento financeiro     |
| `Product`    | Livre                                               | Nome de produto legível    |
| `CostCenter` | Livre                                               | Centro de custo financeiro |
| `AutoStop`   | `true`, `false`                                     | AWS Instance Scheduler     |
| `Backup`     | `Daily7d`, `Weekly30d`, `Monthly90d`, `None`        | AWS Backup                 |

---

## Tags adicionais por stack

`extra_tags` mescla chaves extras no map final e sobrescreve conflitos. As chaves passam por validação de PascalCase.

```hcl
module "standard_tags" {
  source = "../../modules/tags"
  # ...

  extra_tags = {
    Name     = "Platform-SaaS-Evolution-cliente-x"
    Business = "SaaS"
  }
}
```

Chaves como `business-unit`, `business_unit` ou `businessUnit` falham no `terraform plan`.

---

## Override por recurso

```hcl
resource "aws_s3_bucket" "exports" {
  bucket = "escale-exports"

  tags = merge(module.standard_tags.tags, {
    DataClassification = "Confidential"  # sobrescreve apenas esta tag
    Backup             = "Monthly90d"
  })
}
```

---

## Requisitos

Terraform `>= 1.9` — o módulo usa validação entre variáveis (`criticality` e `data_classification` obrigatórias conforme `environment`), recurso introduzido nessa versão.

> **Atenção:** validação entre variáveis é avaliada apenas quando os valores são resolvidos, ou seja, no `terraform plan`. O `terraform validate` retorna sucesso mesmo com um stack de produção sem `criticality`. Pipelines que rodam apenas `validate` não pegam essa regra.
