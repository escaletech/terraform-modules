# terraform-aws-api-gateway-stage

Modulo Terraform para criar e configurar um **Stage** de API Gateway REST, com:

- mapeamento de dominio/base path (opcional para APIs publicas)
- logs de acesso em CloudWatch
- associacao opcional com WAF existente

## O que este modulo cria

- `aws_api_gateway_stage`
- `aws_cloudwatch_log_group`
- `aws_api_gateway_base_path_mapping` (somente quando `private = false`)
- `aws_wafv2_web_acl_association` (somente quando `enable_waf_association = true`)

Tambem consulta a API existente via:

- `data.aws_api_gateway_rest_api`

## Comportamento

- O modulo **nao cria deployment** de API Gateway.
- O stage usa o `deployment_id` informado.
- Se `private = true`, o modulo nao cria `base_path_mapping`.
- Se `base_path = null`, o `base_path_mapping` usa caminho raiz (`""`).
- Se `enable_waf_association = true`, o modulo associa o stage ao `waf_web_acl_arn` informado.
- Se `enable_waf_association = false`, nenhuma associacao com WAF e criada.

## Uso

```hcl
module "api_gateway_stage" {
  source = "git::https://github.com/<org>/terraform-modules.git//modules/api-gateway-stage"

  name         = "prod"
  gateway_api  = "minha-api"
  gateway_api_id = "a1b2c3d4"
  domain       = "api.exemplo.com"
  deployment_id = "xyz123"

  variables = {
    service = "billing"
    env     = "prod"
  }

  base_path = "billing"
  private   = false

  enable_waf_association = true
  waf_web_acl_arn        = "arn:aws:wafv2:us-west-2:123456789012:regional/webacl/meu-waf/11111111-2222-3333-4444-555555555555"
}
```

## Inputs

| Nome | Tipo | Padrao | Obrigatorio | Descricao |
|---|---|---|---|---|
| `name` | `string` | n/a | sim | Nome do stage |
| `gateway_api` | `string` | n/a | sim | Nome da API Gateway |
| `gateway_api_id` | `string` | `null` | nao | ID da API Gateway (quando informado, e usado nos recursos) |
| `domain` | `string` | n/a | sim | Dominio para base path mapping |
| `variables` | `map(string)` | `{}` | nao | Variaveis do stage |
| `base_path` | `string` | `null` | nao | Base path do dominio (`null` usa raiz) |
| `private` | `bool` | `false` | nao | Se `true`, nao cria base path mapping |
| `deployment_id` | `string` | `null` | sim (na pratica) | Deployment existente usado pelo stage |
| `enable_waf_association` | `bool` | `false` | nao | Se `true`, cria associacao do stage com um Web ACL existente |
| `waf_web_acl_arn` | `string` | `null` | condicional | ARN do Web ACL. Necessario quando `enable_waf_association = true` |

## Outputs

Este modulo nao define outputs.

## Observacoes

- O log group e criado com retencao de `400` dias.
- O formato de access log inclui IP, dominio, metodo, path, status, latencia, request ID e e-mail do authorizer.
- Para evitar erro de aplicacao, use `enable_waf_association = true` somente com `waf_web_acl_arn` valido.
