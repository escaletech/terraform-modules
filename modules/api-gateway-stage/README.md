# terraform-aws-api-gateway-stage

Módulo Terraform para criar e configurar um **Stage** de API Gateway REST, com:

- deployment automático (opcional)
- mapeamento de domínio/base path (opcional para APIs públicas)
- logs de acesso em CloudWatch

## O que este módulo cria

- `aws_api_gateway_stage`
- `aws_cloudwatch_log_group`
- `aws_api_gateway_deployment` (somente quando `create_deployment = true`)
- `aws_api_gateway_base_path_mapping` (somente quando `private = false`)

Também consulta a API existente via:

- `data.aws_api_gateway_rest_api`

## Comportamento

- Se `create_deployment = true`, o módulo cria um novo deployment e conecta o stage nele.
- Se `create_deployment = false`, o módulo usa `deployment_id` informado.
- Se `hash` for informado, ele é usado no `trigger` de redeploy (`redeployment = var.hash`).
- Se `private = true`, o módulo não cria `base_path_mapping`.
- Se `base_path = null`, o `base_path_mapping` usa caminho raiz (`""`).

## Uso

```hcl
module "api_gateway_stage" {
  source = "git::https://github.com/<org>/terraform-modules.git//modules/api-gateway-stage"

  name       = "prod"
  gateway_api = "minha-api"
  domain     = "api.exemplo.com"

  variables = {
    service = "billing"
    env     = "prod"
  }

  hash      = "v2026-02-24"
  base_path = "billing"
  private   = false

  # controla se o módulo cria deployment (default = false)
  create_deployment = true

  # opcional: usar API por ID em vez de apenas nome
  # gateway_api_id = "a1b2c3d4"

  # obrigatório quando create_deployment = false
  # deployment_id = "xyz123"
}
```

## Inputs

| Nome | Tipo | Padrão | Obrigatório | Descrição |
|---|---|---|---|---|
| `name` | `string` | n/a | sim | Nome do stage |
| `gateway_api` | `string` | n/a | sim | Nome da API Gateway |
| `gateway_api_id` | `string` | `null` | não | ID da API Gateway (quando informado, é usado nos recursos) |
| `domain` | `string` | n/a | sim | Domínio para base path mapping |
| `variables` | `map(string)` | `{}` | não | Variáveis do stage |
| `hash` | `string` | `null` | não | Hash para forçar redeploy |
| `create_deployment` | `bool` | `false` | não | Se `true`, cria `aws_api_gateway_deployment`; se `false`, usa `deployment_id` |
| `base_path` | `string` | `null` | não | Base path do domínio (`null` usa raiz) |
| `private` | `bool` | `false` | não | Se `true`, não cria base path mapping |
| `deployment_id` | `string` | `null` | não | Deployment existente (usar quando `create_deployment = false`) |

## Outputs

Este módulo não define outputs.

## Observações

- O log group é criado com retenção de `400` dias.
- O formato de access log inclui IP, domínio, método, path, status, latência, request ID e e-mail do authorizer.
