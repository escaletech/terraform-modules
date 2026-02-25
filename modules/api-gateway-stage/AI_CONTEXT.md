# AI Context - api-gateway-stage

Este arquivo ajuda assistentes de IA (Copilot, ChatGPT, Claude, etc.) a entender rapidamente este modulo Terraform.

## Objetivo do modulo

Criar e configurar um `aws_api_gateway_stage` para uma API Gateway REST existente, com:

- logs de acesso no CloudWatch
- base path mapping opcional
- associacao opcional com WAF

## Recursos criados

- `aws_api_gateway_stage.stage`
- `aws_cloudwatch_log_group.log_api_gateway`
- `aws_api_gateway_base_path_mapping.mapping` (somente quando `private = false`)
- `aws_wafv2_web_acl_association.waf_association` (somente quando `enable_waf_association = true`)

## Recurso consultado

- `data.aws_api_gateway_rest_api.gateway_api` (busca API por nome)

## Regras importantes (nao violar)

1. Este modulo **nao cria deployment** de API Gateway.
2. `deployment_id` deve ser informado para o stage funcionar.
3. `create_deployment` e `hash` foram descontinuados/comentados e nao devem ser usados em exemplos novos.
4. Se `enable_waf_association = true`, deve existir `waf_web_acl_arn` valido.
5. Se `private = true`, nao criar `aws_api_gateway_base_path_mapping`.

## Inputs principais

- `name` (string): nome do stage.
- `gateway_api` (string): nome da API existente.
- `gateway_api_id` (string|null): ID da API (quando informado, priorizado nos recursos).
- `domain` (string): dominio para base path mapping.
- `variables` (map(string)): variaveis do stage.
- `base_path` (string|null): `null` vira raiz (`""`).
- `private` (bool): controla criacao do base path mapping.
- `deployment_id` (string|null): deployment existente usado pelo stage.
- `enable_waf_association` (bool): habilita associacao com WAF.
- `waf_web_acl_arn` (string|null): ARN do Web ACL para associacao.

## Exemplo recomendado

```hcl
module "api_gateway_stage" {
  source = "git::https://github.com/<org>/terraform-modules.git//modules/api-gateway-stage"

  name          = "prod"
  gateway_api   = "minha-api"
  domain        = "api.exemplo.com"
  deployment_id = "abc123"

  base_path = "billing"
  private   = false

  enable_waf_association = true
  waf_web_acl_arn        = "arn:aws:wafv2:us-west-2:123456789012:regional/webacl/meu-waf/uuid"
}
```

## Prompt curto sugerido para IA

"Atualize este modulo Terraform sem reintroduzir `create_deployment`/`hash`. Preserve o uso de `deployment_id` no stage e mantenha WAF opcional via `enable_waf_association` + `waf_web_acl_arn`."
