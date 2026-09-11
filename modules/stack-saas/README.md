# stack-saas

Modulo Terraform para subir uma stack com EC2, S3, ALB (listener rules + target groups),
Route53 (DNS) e CloudWatch (metricas e alarmes) para um cliente.

## O que ele cria
- EC2 com user-data para Docker + CloudWatch Agent
- Security Group com portas configuraveis
- Secrets Manager (secret inicial)
- S3 bucket e IAM policy para acesso ao bucket
- Target Groups + Listener Rules no ALB
- Registros DNS (Route53)
- Alarmes no CloudWatch + SNS + subscription para Lambda

## Requisitos
- VPC e subnets existentes
- ALB e listener existentes (arn do listener e info do LB)
- Hosted Zone do Route53 existente
- AMI compativel com `yum` (ex: Amazon Linux 2)

## Como usar

```hcl
module "stack_saas" {
  source = "github.com/escaletech/terraform-modules/modules/stack-saas"

  # obrigatorios
  instance_type = "t3.large"
  ami           = "ami-xxxxxxxx"
  client_name   = "cliente-x"
  environment   = "staging"
  vpc_id        = "vpc-xxxxxxxx"
  subnet_ids    = ["subnet-aaa", "subnet-bbb"]
  listener_arn  = "arn:aws:elasticloadbalancing:..."
  lb_id         = "ZXXXXXXXXXXXX"
  lb_name       = "dualstack.meu-alb-123456.us-east-1.elb.amazonaws.com"
  route53_id    = "ZYYYYYYYYYYYY"
  ipv4_cidr_blocks = ["10.0.0.0/16"]

  dns_chatwoot  = "chat.cliente-x.seudominio.com"
  dns_evolution = "evo.cliente-x.seudominio.com"
  dns_builder   = "builder.cliente-x.seudominio.com"
  dns_bot       = "bot.cliente-x.seudominio.com"

  # tags: gere o map pelo modulo canonico modules/tags/
  tags = module.standard_tags.tags

  # opcionais
  name_prefix     = "platform-conversational-cliente-x"
  role_prefix     = "platform-conversational-cliente-x-01"
  key_name        = "minha-chave-ssh"
  s3_name         = "cliente-x-saas"
  create_s3       = true
  ports_ingress_allowed = [22, 80, 443]
  containers_name = ["chatwoot", "sidekiq", "typebot-builder", "typebot-viewer", "evolution"]
  enable_api_gateway = true
  api_gateway_name = "api.saas.escale.ai"
  api_gateway_vpc_link_name = "vpc-link-api-escale-saas"
  api_gateway_certificate_domain = "*.saas.xclapi.in"
  api_gateway_zone_name = "saas.xclapi.in" # dominio final: <client_name>.saas.xclapi.in

  # opcional: override dos IPs por app
  listener_source_ips = {
    "cliente-x-chat" = ["10.0.0.0/16"]
  }
}
```

## Tags: padronizacao do ambiente

> **Nota:** as tags obrigatorias deste modulo mudaram de `Owner`, `Partner`, `Business` e `Product`
> para `Environment`, `Partner`, `Operation`, `Owner`, `ManagedBy` e `Repository`. A mudanca faz parte
> da padronizacao de tags do ambiente, que unifica o esquema de tagueamento em todos os modulos deste
> repositorio para permitir rastreio de custo, ownership e classificacao de dados de forma consistente.
>
> As chaves seguem **PascalCase**, o padrao ja em uso nos stacks. Chaves em lowercase, kebab-case ou
> snake_case sao rejeitadas na validacao — tags na AWS sao case-sensitive, e `Partner` e `partner`
> contam como tags distintas no Cost Explorer.

O map deve ser gerado pelo modulo canonico [`modules/tags`](../tags/README.md), que valida os
valores e monta as chaves no formato esperado:

```hcl
module "standard_tags" {
  source      = "github.com/escaletech/terraform-modules/modules/tags"
  environment = "Staging"
  partner     = "parceiro-y"
  operation   = "operacao-z"
  owner       = "Time X"
  repository  = "https://github.com/escaletech/infra-cliente-x"

  # criticality e data_classification sao obrigatorias quando environment = "Production"
}

module "stack_saas" {
  source = "github.com/escaletech/terraform-modules/modules/stack-saas"
  tags   = module.standard_tags.tags
  # ...
}
```

**Impacto:** stacks que ainda passam o conjunto antigo de tags vao falhar na validacao durante o
`terraform plan`. A migracao consiste em substituir o map literal por `module.standard_tags.tags`.

Stacks que ja usam `Owner`, `Partner`, `Environment` e `Repository` em PascalCase mantem essas quatro
chaves — so precisam acrescentar `Operation` e `ManagedBy`.

## Variaveis

| Nome | Tipo | Obrigatorio | Default | Descricao |
|------|------|-------------|---------|-----------|
| instance_type | string | sim | - | Tipo da instancia EC2 |
| ami | string | sim | - | AMI usada na EC2 |
| tags | map(string) | sim | - | Tags do stack em PascalCase. Obrigatorias: `Environment`, `Partner`, `Operation`, `Owner`, `ManagedBy`, `Repository`. Use `module.standard_tags.tags` (ver [modules/tags](../tags/README.md)) |
| client_name | string | sim | - | Nome do cliente |
| environment | string | sim | - | Ambiente |
| vpc_id | string | sim | - | VPC onde os recursos serao criados |
| subnet_ids | list(string) | sim | - | Subnets do ambiente |
| listener_arn | string | sim | - | ARN do listener do ALB |
| lb_id | string | sim | - | Zone ID do ALB |
| lb_name | string | sim | - | DNS do ALB |
| route53_id | string | sim | - | Hosted Zone ID do Route53 |
| ipv4_cidr_blocks | list(string) | sim | - | CIDR blocks liberados no SG |
| dns_chatwoot | string | sim | - | DNS do Chatwoot |
| dns_evolution | string | sim | - | DNS do Evolution |
| dns_builder | string | sim | - | DNS do Typebot Builder |
| dns_bot | string | sim | - | DNS do Typebot Viewer |
| name_prefix | string | nao | "" | Prefixo para nomes IAM/EC2 |
| role_prefix | string | nao | "" | Prefixo para nomes IAM (role/policies/profile) |
| key_name | string | nao | "" | Key pair para SSH |
| initial_secret_value | string | nao | "{\"placeholder\": \"init\"}" | Valor inicial do secret |
| ports_ingress_allowed | list(number) | nao | [22,80,443] | Portas liberadas no SG |
| s3_name | string | nao | "" | Nome do bucket S3 |
| create_s3 | bool | nao | true | Criar bucket S3 e anexar policy |
| enable_api_gateway | bool | nao | false | Criar resources do API Gateway para Escale |
| api_gateway_name | string | nao | "api.saas.escale.ai" | Nome do API Gateway REST existente |
| api_gateway_vpc_link_name | string | nao | "vpc-link-api-escale-saas" | Nome do VPC Link existente |
| api_gateway_certificate_domain | string | nao | "*.saas.xclapi.in" | Dominio do certificado ACM |
| api_gateway_zone_name | string | nao | "saas.xclapi.in" | Zona Route53 do dominio (host do custom domain e criado como <client_name>.<zona>) |
| containers_name | list(string) | nao | ["chatwoot","sidekiq","typebot-builder","typebot-viewer","evolution"] | Containers monitorados |
| listener_source_ips | map(list(string)) | nao | {} | Override de IPs por app nos listener rules |

## Observacoes importantes
- O EC2 sobe com Docker usando apenas o socket local; se quiser expor TCP, ajuste o user-data manualmente.
- Os alarmes de containers assumem o namespace `SaaS-DockerMetrics-<client_name>`.
- A policy do bucket S3 agora e anexada na role da instancia EC2.
- A instancia usa a primeira subnet da lista `subnet_ids`.
