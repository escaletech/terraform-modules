# Módulo `loadbalancer-target-listener`

Este módulo Terraform cria:

- um `aws_lb_target_group`
- um `aws_lb_target_group_attachment` opcional
- uma `aws_lb_listener_rule` que encaminha tráfego para o target group criado

O foco do módulo é registrar um backend em um ALB já existente e associá-lo a uma regra de listener com condições de roteamento.

## Recursos criados

| Recurso | Nome | Observações |
| --- | --- | --- |
| `aws_lb_target_group` | `target` | Sempre criado |
| `aws_lb_target_group_attachment` | `internal` | Criado condicionalmente |
| `aws_lb_listener_rule` | `listener` | Sempre criada e aponta para o target group do módulo |

## Exemplo de uso

```hcl
module "app_listener_target" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer-target-listener"

  vpc_id       = "vpc-0123456789abcdef0"
  listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/50dc6c495c0c9188/6d0ecf831fb6c8f5"

  target_name     = "app-api"
  target_type     = "ip"
  target_port     = 8080
  target_protocol = "HTTP"

  health_interval   = 30
  health_path       = "/health"
  health_statuscode = "200-399"
  health_timout     = 5

  host_header  = ["api.example.com"]
  path_pattern = ["/v1/*"]

  ip = "10.0.10.15"
}
```

## Comportamento

### Target group

O target group sempre é criado com:

- `name = var.target_name`
- `target_type = var.target_type`
- `port = var.target_port`
- `protocol = var.target_protocol`
- `vpc_id = var.vpc_id`

O health check usa os parâmetros expostos pelo módulo, incluindo `health_interval`. O nome da variável de timeout é `health_timout`, exatamente como está no código.

### Attachment opcional

O attachment do target group segue esta lógica:

- se `enable_attachment` for definido, ele tem precedência
- se `enable_attachment = true`, cria o attachment
- se `enable_attachment = false`, não cria o attachment
- se `enable_attachment = null`, o attachment só é criado quando `target_type == "ip"` e `ip != ""`

Quando criado, o attachment usa:

- `target_id = var.ip`
- `port = var.target_port`

### Listener rule

A listener rule sempre faz `forward` para o target group criado no módulo.

As condições são adicionadas dinamicamente apenas quando as listas correspondentes possuem itens:

- `host_header`
- `path_pattern`
- `source_ip`

## Inputs

| Variável | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `vpc_id` | `string` | n/a | ID da VPC onde o target group será criado |
| `listener_arn` | `string` | n/a | ARN do listener do ALB onde a regra será criada |
| `target_name` | `string` | n/a | Nome do target group |
| `target_type` | `string` | `"ip"` | Tipo do target group, por exemplo `ip` ou `instance` |
| `target_port` | `number` | n/a | Porta do target group e do attachment |
| `target_protocol` | `string` | `"HTTP"` | Protocolo do target group |
| `health_interval` | `number` | `30` | Intervalo do health check em segundos |
| `health_path` | `string` | `"/"` | Caminho do health check |
| `health_statuscode` | `string` | `"200"` | Matcher de status do health check |
| `health_timout` | `number` | `5` | Timeout do health check |
| `healthy_threshold` | `number` | `2` | Threshold de sucesso do health check |
| `unhealthy_threshold` | `number` | `2` | Threshold de falha do health check |
| `host_header` | `list(string)` | `[]` | Valores para condição `host_header` da listener rule |
| `path_pattern` | `list(string)` | `[]` | Valores para condição `path_pattern` da listener rule |
| `source_ip` | `list(string)` | `[]` | Valores para condição `source_ip` da listener rule |
| `ip` | `string` | `""` | IP registrado no attachment quando aplicável |
| `enable_attachment` | `bool` | `null` | Override opcional para forçar ou desabilitar a criação do attachment |

## Outputs

| Output | Descrição |
| --- | --- |
| `arn` | ARN do target group criado |

## Limitações e observações

- O módulo não expõe `priority` para a `aws_lb_listener_rule`. A priorização fica dependente do comportamento do provider/AWS na criação da regra.
- O módulo não valida combinações inválidas de entrada, como `target_type = "instance"` com `enable_attachment = true` e `ip` vazio.
- Se nenhuma condição for informada em `host_header`, `path_pattern` ou `source_ip`, a regra ainda é declarada pelo módulo. Dependendo da validação do provider/AWS, isso pode não ser aceito.
- O output disponível hoje retorna apenas o ARN do target group.

## Arquivos do módulo

- [`listener.tf`](/Users/joaoanselmo/Documents/GitHub/terraform-modules/modules/loadbalancer-target-listener/listener.tf)
- [`target.tf`](/Users/joaoanselmo/Documents/GitHub/terraform-modules/modules/loadbalancer-target-listener/target.tf)
- [`variable.tf`](/Users/joaoanselmo/Documents/GitHub/terraform-modules/modules/loadbalancer-target-listener/variable.tf)
- [`outputs.tf`](/Users/joaoanselmo/Documents/GitHub/terraform-modules/modules/loadbalancer-target-listener/outputs.tf)
