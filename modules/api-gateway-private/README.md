# api-gateway-private

Modulo Terraform para criar um API Gateway REST com endpoint **PRIVATE**, custom domain, Route53 record, VPC Endpoint opcional e suporte a CORS.

## Uso

### Exemplo completo (VPC Endpoint + CORS)

```hcl
module "api-escale-saas" {
  source     = "github.com/escaletech/terraform-modules//modules/api-gateway-private"
  depends_on = [aws_security_group.sg_vpc_endpoint_apigateway_saas]

  name            = local.api_name
  domain          = local.domain_api_escale_saas
  zone            = local.zona_dns
  private_zone    = true
  certificate_arn = data.aws_acm_certificate.saas-escale-ai.arn

  type_endpoint       = "REGIONAL"
  create_vpc_endpoint = true
  vpc_id              = data.aws_vpc.esc_saas_vpc.id
  vpc_endpoint_subnet_ids = [
    data.aws_subnets.esc_saas_private_subnets.ids[0],
    data.aws_subnets.esc_saas_private_subnets.ids[1],
  ]
  vpc_endpoint_security_group_ids = [
    aws_security_group.sg_vpc_endpoint_apigateway_saas.id
  ]

  create_cors_options   = true
  create_proxy_resource = true
  cors_paths            = ["/{proxy+}"]
  cors_allowed_origins = [
    "https://chat.staging.saas.escale.ai",
    "https://admin.saas.escale.ai",
    "https://api.saas.escale.ai"
  ]
}
```

### Usando VPC Endpoint existente

```hcl
module "api_gateway_private" {
  source = "github.com/escaletech/terraform-modules//modules/api-gateway-private"

  name            = "my-private-api"
  domain          = "api.internal.example.com"
  zone            = "internal.example.com"
  private_zone    = true
  certificate_arn = data.aws_acm_certificate.cert.arn

  type_endpoint    = "REGIONAL"
  vpc_endpoint_ids = [aws_vpc_endpoint.apigw.id]
}
```

### Apenas com CORS (sem criar VPC Endpoint)

```hcl
module "api_gateway_private" {
  source = "github.com/escaletech/terraform-modules//modules/api-gateway-private"

  name            = "my-private-api"
  domain          = "api.internal.example.com"
  zone            = "internal.example.com"
  certificate_arn = data.aws_acm_certificate.cert.arn

  vpc_endpoint_ids = [aws_vpc_endpoint.apigw.id]

  create_cors_options   = true
  create_proxy_resource = true
  cors_paths            = ["/{proxy+}"]
  cors_allowed_origins  = ["https://app.example.com"]
}
```

## VPC Endpoint

Quando `create_vpc_endpoint = true`, o modulo cria:

- Um **VPC Endpoint** do tipo Interface para o servico `execute-api`
- Um **Security Group** que permite HTTPS (443) a partir do CIDR da VPC
- Regra de egress para todo trafego de saida

Os Security Groups informados em `vpc_endpoint_security_group_ids` sao adicionados junto ao SG criado pelo modulo.

## CORS

Quando `create_cors_options = true`, o modulo cria para cada path em `cors_paths`:

- Method `OPTIONS`
- Integration do tipo `MOCK`
- Response headers `Access-Control-Allow-Headers`, `Access-Control-Allow-Methods` e `Access-Control-Allow-Origin`
- Validacao de origem via VTL template usando a lista `cors_allowed_origins`

Se `create_proxy_resource = true` e `cors_paths` inclui `/{proxy+}`, o modulo cria o resource `{proxy+}` automaticamente.

## Inputs

| Nome | Tipo | Descricao | Obrigatorio | Default |
|------|------|-----------|-------------|---------|
| `name` | `string` | Nome do API Gateway | sim | - |
| `domain` | `string` | Dominio customizado para o API Gateway | sim | - |
| `zone` | `string` | Zona Route53 onde o dominio sera criado | sim | - |
| `private_zone` | `bool` | Se a zona Route53 e privada | nao | `true` |
| `certificate_arn` | `string` | ARN do certificado ACM | sim | - |
| `type_endpoint` | `string` | Tipo de endpoint do custom domain (`REGIONAL` ou `EDGE`) | nao | `REGIONAL` |
| `vpc_endpoint_ids` | `list(string)` | IDs de VPC Endpoints existentes | nao | `[]` |
| `create_vpc_endpoint` | `bool` | Criar VPC Endpoint pelo modulo | nao | `false` |
| `vpc_id` | `string` | ID da VPC (obrigatorio quando `create_vpc_endpoint = true`) | nao | `null` |
| `vpc_endpoint_subnet_ids` | `list(string)` | IDs das subnets para o VPC Endpoint | nao | `[]` |
| `vpc_endpoint_security_group_ids` | `list(string)` | IDs de Security Groups adicionais para o VPC Endpoint | nao | `[]` |
| `vpc_endpoint_private_dns_enabled` | `bool` | Habilitar DNS privado no VPC Endpoint | nao | `true` |
| `vpc_endpoint_service_name` | `string` | Override do service name do VPC Endpoint | nao | `null` |
| `create_cors_options` | `bool` | Criar method OPTIONS para CORS nos paths especificados | nao | `false` |
| `create_proxy_resource` | `bool` | Criar resource `/{proxy+}` quando presente em `cors_paths` | nao | `true` |
| `cors_paths` | `list(string)` | Paths que devem receber method OPTIONS para CORS | nao | `[]` |
| `cors_allowed_origins` | `list(string)` | Lista de origens permitidas para CORS | nao | `[]` |

## Outputs

| Nome | Descricao |
|------|-----------|
| `id` | ID do API Gateway REST |
| `root_resource_api_id` | ID do resource root (`/`) |
| `gateway_api_arn` | ARN do API Gateway |
| `vpc_endpoint_ids` | IDs dos VPC Endpoints efetivamente utilizados |
| `vpc_endpoint_security_group_ids` | IDs dos Security Groups efetivamente utilizados no VPC Endpoint |
