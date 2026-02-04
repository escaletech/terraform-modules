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

  tags = {
    owner    = "time-x"
    partner  = "parceiro-y"
    business = "produto-z"
    product  = "saas"
  }

  # opcionais
  name_prefix     = "platform-conversational-cliente-x"
  key_name        = "minha-chave-ssh"
  s3_name         = "cliente-x-saas"
  create_s3       = true
  ports_ingress_allowed = [22, 80, 443]
  containers_name = ["chatwoot", "sidekiq", "typebot-builder", "typebot-viewer", "evolution"]

  # opcional: override dos IPs por app
  listener_source_ips = {
    "cliente-x-chat" = ["10.0.0.0/16"]
  }
}
```

## Variaveis

| Nome | Tipo | Obrigatorio | Default | Descricao |
|------|------|-------------|---------|-----------|
| instance_type | string | sim | - | Tipo da instancia EC2 |
| ami | string | sim | - | AMI usada na EC2 |
| tags | map(string) | sim | - | Tags obrigatorias (owner, partner, business, product) |
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
| key_name | string | nao | "" | Key pair para SSH |
| initial_secret_value | string | nao | "{\"placeholder\": \"init\"}" | Valor inicial do secret |
| ports_ingress_allowed | list(number) | nao | [22,80,443] | Portas liberadas no SG |
| s3_name | string | nao | "" | Nome do bucket S3 |
| create_s3 | bool | nao | true | Criar bucket S3 e anexar policy |
| containers_name | list(string) | nao | ["chatwoot","sidekiq","typebot-builder","typebot-viewer","evolution"] | Containers monitorados |
| listener_source_ips | map(list(string)) | nao | {} | Override de IPs por app nos listener rules |

## Observacoes importantes
- O EC2 sobe com Docker usando apenas o socket local; se quiser expor TCP, ajuste o user-data manualmente.
- Os alarmes de containers assumem o namespace `SaaS-DockerMetrics-<client_name>`.
- A policy do bucket S3 agora e anexada na role da instancia EC2.
- A instancia usa a primeira subnet da lista `subnet_ids`.
