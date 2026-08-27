# waf-shared-platform

Web ACL WAFv2 **REGIONAL** compartilhado (1 por conta/região, N associations). Fecha stages REST sem WAF e, de forma opt-in, ALB.

v1: associations **desligadas** enquanto `stage_arns` e `alb_arns` estão vazios (tráfego zero). CRS / KnownBadInputs / SQLi em **count** no grupo inteiro. Único **block** gerenciado: IP Reputation. IP sets allow/deny começam vazios (no-op).

Não use este ACL como allowlist global de IP (serviços públicos e admin no mesmo ACL). Rate limit também não entra aqui (vale para o ACL inteiro).

Não misturar com o PR de custom domain EDGE vs REGIONAL.

## O que cria

- `aws_wafv2_web_acl` (`WAF-shared-platform`)
- IP sets `${name}-allow` e `${name}-deny`
- Log group `aws-waf-logs-shared-platform` + resource policy + `logging_configuration`
- Alarme CloudWatch `BlockedRequests` (dimensão `Rule=ALL`)
- `aws_wafv2_web_acl_association` só para as chaves presentes nos mapas

## Ruleset (v1)

| Prio | Regra | Ação |
|---|---|---|
| 0 | Allow IP set | allow (vazio = no-op) |
| 1 | `AWSManagedRulesAmazonIpReputationList` | **block** |
| 2 | `AWSManagedRulesCommonRuleSet` | **count** (override do grupo) |
| 3 | `AWSManagedRulesKnownBadInputsRuleSet` | **count** |
| 4 | `AWSManagedRulesSQLiRuleSet` | **count** |
| 5 | Deny IP set | block (vazio = no-op) |

`default_action` = allow.

## Uso (primeiro apply — zero association)

```hcl
module "waf_shared_platform" {
  source = "github.com/escaletech/terraform-modules/modules/waf-shared-platform"

  name = "WAF-shared-platform"

  stage_arns = {}
  alb_arns   = {}

  tags = {
    Environment = "production"
    Repository  = "https://github.com/escaletech/escale-saas-clients"
  }
}
```

## Uso (canário REST)

```hcl
stage_arns = {
  blocklist-east-2 = "arn:aws:apigateway:us-east-2::/restapis/76yqy9u4i8/stages/production"
}
```

Um stage REST aceita **um** Web ACL. Só associe ARNs com `webAclArn` vazio. Rollback: remover a chave do mapa (ou `aws wafv2 disassociate-web-acl`). Não dê `destroy` no ACL se ainda houver association.

## O que não associar neste módulo

- ALB `escale-saas-external` us-east-2 (`WAF-K2`)
- REST `production-k2-communication-gateway` (`WAF-Communication-Gateway`)
- Stages xclapi (ACL dedicado ou `WAF-Default`)

## ISO 27002:2022 → recurso

O nome do ACL **não** leva ISO. Evidência:

| Controle | Recurso |
|---|---|
| 8.20 / 8.21 perímetro | `aws_wafv2_web_acl_association` |
| 5.7 threat intel | `AWSManagedRulesAmazonIpReputationList` (block) |
| 8.26 / 8.28 appsec | CRS / SQLi / KnownBadInputs em **count** no v1 |
| 8.15 / 8.16 log e monitoramento | `aws-waf-logs-*` + alarme `BlockedRequests` |
| 8.9 configuração | ACL só via Terraform |
| 8.6 DoS | lista DDoS da Reputation; rate limit **fora** deste ACL |
| 8.23 filtragem web | AnonymousIpList **não** no v1 |

## Inputs

| Nome | Tipo | Padrão | Descrição |
|---|---|---|---|
| `name` | `string` | `WAF-shared-platform` | Nome do Web ACL |
| `description` | `string` | (texto do módulo) | Descrição |
| `scope` | `string` | `REGIONAL` | Só REGIONAL |
| `allow_ipv4_cidrs` | `list(string)` | `[]` | CIDRs allow (no-op se vazio) |
| `deny_ipv4_cidrs` | `list(string)` | `[]` | CIDRs deny (no-op se vazio) |
| `stage_arns` | `map(string)` | `{}` | ARNs de stage REST |
| `alb_arns` | `map(string)` | `{}` | ARNs de ALB |
| `log_group_name` | `string` | `aws-waf-logs-shared-platform` | Deve começar com `aws-waf-logs-` |
| `log_retention_in_days` | `number` | `30` | Retenção |
| `alarm_blocked_requests_threshold` | `number` | `50` | Threshold do alarme |
| `alarm_period_seconds` | `number` | `300` | Período |
| `alarm_evaluation_periods` | `number` | `3` | Períodos |
| `alarm_actions` | `list(string)` | `[]` | SNS etc. |
| `tags` | `map(string)` | `{}` | Tags |

## Outputs

| Nome | Descrição |
|---|---|
| `web_acl_arn` | ARN do ACL |
| `web_acl_id` | ID |
| `web_acl_name` | Nome |
| `log_group_name` / `log_group_arn` | Destino de log |
| `allow_ip_set_arn` / `deny_ip_set_arn` | IP sets |
| `blocked_requests_alarm_name` | Alarme |

## Requisitos

- AWS provider `>= 5.0`
- Terraform `>= 1.3`
