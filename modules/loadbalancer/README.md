# Módulo Load Balancer (ALB / NLB)

Módulo Terraform para criar um Application Load Balancer (ALB) ou Network Load Balancer (NLB) na AWS, incluindo security groups, listeners, target groups e target group attachments.

## Uso

### ALB

```hcl
module "alb" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer"

  lb_type    = "alb"
  name       = "my-alb"
  vpc_id     = "vpc-0123456789abcdef0"
  alb_subnet_ids = ["subnet-aaa", "subnet-bbb"]

  alb_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."

  tags = {
    Environment = "production"
  }
}
```

### NLB

```hcl
module "nlb" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer"

  lb_type    = "nlb"
  name       = "my-nlb"
  vpc_id     = "vpc-0123456789abcdef0"
  nlb_subnet_ids = ["subnet-aaa", "subnet-bbb"]

  nlb_target_groups = [
    {
      name        = "tg-app"
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
      targets = [
        { target_id = "i-0123456789abcdef0" },
        { target_id = "i-0123456789abcdef1" },
      ]
    }
  ]

  nlb_listeners = [
    {
      port              = 80
      protocol          = "TCP"
      target_group_name = "tg-app"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### NLB apontando para ALB

Crie o ALB com este módulo e utilize o output `lb_arn` como `target_id` no NLB:

```hcl
module "alb" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer"

  lb_type    = "alb"
  name       = "my-alb"
  vpc_id     = "vpc-0123456789abcdef0"
  alb_subnet_ids = ["subnet-aaa", "subnet-bbb"]

  alb_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
}

module "nlb" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer"

  lb_type    = "nlb"
  name       = "my-nlb"
  vpc_id     = "vpc-0123456789abcdef0"
  nlb_subnet_ids = ["subnet-aaa", "subnet-bbb"]

  nlb_target_groups = [
    {
      name        = "tg-to-alb"
      port        = 443
      protocol    = "TCP"
      target_type = "alb"
      targets = [
        { target_id = module.alb.lb_arn }
      ]
    }
  ]

  nlb_listeners = [
    {
      port              = 443
      protocol          = "TCP"
      target_group_name = "tg-to-alb"
    }
  ]
}
```

## Variáveis de Entrada

### Gerais

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| lb_type | Tipo do load balancer: `alb` ou `nlb`. | `string` | `"alb"` | no |
| name | Nome do load balancer. | `string` | n/a | yes |
| tags | Tags para os recursos. | `map(string)` | `{}` | no |
| enable_deletion_protection | Habilitar proteção contra exclusão. | `bool` | `true` | no |
| vpc_id | ID da VPC. Se nulo, `vpc_name` é utilizado. | `string` | `null` | no |
| vpc_name | Nome (tag) da VPC para lookup quando `vpc_id` é nulo. | `string` | `null` | no |

### ALB

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| alb_internal | Se o ALB é interno (privado). | `bool` | `false` | no |
| alb_subnet_ids | IDs das subnets para o ALB. | `list(string)` | `[]` | yes (quando `lb_type = "alb"`) |
| alb_security_group_ids | IDs de security groups existentes para o ALB. | `list(string)` | `[]` | no |
| alb_create_security_group | Criar security group para o ALB. | `bool` | `true` | no |
| alb_ingress_ports | Portas de ingress do security group do ALB. | `list(number)` | `[80, 443]` | no |
| alb_ingress_cidr_blocks | CIDRs de ingress do security group do ALB. | `list(string)` | `["0.0.0.0/0"]` | no |
| alb_egress_cidr_blocks | CIDRs de egress do security group do ALB. | `list(string)` | `["0.0.0.0/0"]` | no |
| alb_egress_ipv6_cidr_blocks | CIDRs IPv6 de egress do security group do ALB. | `list(string)` | `["::/0"]` | no |
| alb_enable_default_listeners | Criar listeners padrão HTTP→HTTPS e HTTPS fixed-response. | `bool` | `true` | no |
| alb_certificate_arn | ARN do certificado ACM para o listener HTTPS do ALB. | `string` | `null` | no |
| alb_https_fixed_response | Resposta fixa para o listener HTTPS do ALB. | `object(...)` | `{ status_code = 404, message_body = "Not Found", content_type = "text/plain" }` | no |

### NLB

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| nlb_internal | Se o NLB é interno. | `bool` | `true` | no |
| nlb_subnet_ids | IDs das subnets para o NLB. | `list(string)` | `[]` | yes (quando `lb_type = "nlb"`) |
| nlb_security_group_ids | IDs de security groups existentes para o NLB. | `list(string)` | `[]` | no |
| nlb_create_security_group | Criar security group para o NLB. | `bool` | `true` | no |
| nlb_ingress_ports | Portas de ingress do security group do NLB. | `list(number)` | `[80, 443]` | no |
| nlb_ingress_cidr_blocks | CIDRs de ingress do security group do NLB. | `list(string)` | `["0.0.0.0/0"]` | no |
| nlb_additional_ingress_rules | Regras de ingress adicionais para o security group do NLB. | `list(object(...))` | `[]` | no |
| nlb_egress_cidr_blocks | CIDRs de egress do security group do NLB. | `list(string)` | `["0.0.0.0/0"]` | no |
| nlb_egress_ipv6_cidr_blocks | CIDRs IPv6 de egress do security group do NLB. | `list(string)` | `["::/0"]` | no |
| nlb_enable_cross_zone_load_balancing | Habilitar cross-zone load balancing. | `bool` | `true` | no |
| nlb_listeners | Listeners do NLB. Cada item deve ter `target_group_arn` ou `target_group_name`. | `list(object(...))` | `[]` | no |
| nlb_target_groups | Target groups do NLB. | `list(object(...))` | `[]` | no |

### nlb_target_groups

Cada item do `nlb_target_groups` aceita os seguintes campos:

| Field | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| name | Nome do target group. | `string` | n/a | yes |
| port | Porta do target group. | `number` | n/a | yes |
| protocol | Protocolo (`TCP`, `TLS`, `UDP`, `TCP_UDP`). | `string` | n/a | yes |
| target_type | Tipo do target (`instance`, `ip`, `alb`). | `string` | `"instance"` | no |
| vpc_id | VPC ID para o target group (sobrescreve o padrão do módulo). | `string` | `null` | no |
| health_check | Configuração de health check. | `object(...)` | `null` | no |
| targets | Lista de targets para registrar no target group. | `list(object(...))` | `[]` | no |
| tags | Tags adicionais para o target group. | `map(string)` | `{}` | no |

### targets

Cada item do `targets` aceita os seguintes campos:

| Field | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| target_id | ID do target (instance ID, IP ou ARN do ALB). | `string` | n/a | yes |
| port | Porta do target (opcional, herda do target group). | `number` | `null` | no |
| availability_zone | Zona de disponibilidade (usado com `target_type = "ip"` cross-zone). | `string` | `null` | no |

## Saídas

| Name | Description |
| --- | --- |
| lb_arn | ARN do load balancer criado. |
| lb_dns_name | DNS name do load balancer criado. |
| lb_zone_id | Zone ID do load balancer criado. |
| security_group_ids | IDs dos security groups associados ao load balancer. |
| nlb_target_group_arns | Map de ARNs dos target groups do NLB (chave = nome do target group). |
