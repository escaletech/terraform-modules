# terraform-module ecs-service-update

Modulo Terraform para criar/atualizar um servico ECS Fargate com suporte opcional a:
- balanceamento de carga
- estrategia com FARGATE + FARGATE_SPOT
- auto scaling por CPU e memoria

## Recursos criados

- `aws_ecs_service.ecs_service_update`
- `aws_appautoscaling_target.ecs-target` (quando `auto_scaling = true`)
- `aws_appautoscaling_policy.ecs_policy_memory` (quando `auto_scaling = true`)
- `aws_appautoscaling_policy.ecs_policy_cpu` (quando `auto_scaling = true`)

## Requisitos

- Terraform compativel com uso de `optional(...)` em tipos de objeto.
- Provider AWS configurado no projeto consumidor.
- `task_definition_arn` ja existente.

## Uso basico

```hcl
module "ecs_service_update" {
  source = "./modules/ecs-service-update"

  service_name         = "my-service"
  cluster_name         = "my-ecs-cluster"
  task_definition_arn  = "arn:aws:ecs:us-west-2:123456789012:task-definition/my-service:15"
  subnets              = ["subnet-aaa", "subnet-bbb"]
  security_groups      = ["sg-123"]
  desire_count         = 2
  assign_public_ip     = false
  container_port       = 8080
  target_group_arn     = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/tg/abc"
  health_check_grace_period_seconds = 60

  tags = {
    owner    = "team-platform"
    partner  = "engineering"
    business = "core"
    product  = "checkout"
  }
}
```

## Uso com Spot + Auto Scaling

```hcl
module "ecs_service_update" {
  source = "./modules/ecs-service-update"

  service_name         = "my-service"
  cluster_name         = "my-ecs-cluster"
  task_definition_arn  = "arn:aws:ecs:us-west-2:123456789012:task-definition/my-service:15"
  subnets              = ["subnet-aaa", "subnet-bbb"]
  security_groups      = ["sg-123"]
  desire_count         = 2
  assign_public_ip     = false

  spot                 = true
  weight_fargate       = 1
  weight_fargate_spot  = 2

  auto_scaling         = true
  min_capacity         = 2
  max_capacity         = 8
  cpu_target           = 60
  memory_target        = 80

  load_balancers = [
    {
      container_name   = "my-service"
      container_port   = 8080
      target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/tg-a/aaa"
    },
    {
      container_name   = "my-service"
      container_port   = 8081
      target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/tg-b/bbb"
    }
  ]

  tags = {
    owner    = "team-platform"
    partner  = "engineering"
    business = "core"
    product  = "checkout"
  }
}
```

## Inputs

| Nome | Tipo | Default | Obrigatorio | Descricao |
|---|---|---|---|---|
| `service_name` | `string` | n/a | sim | Nome do servico ECS. |
| `cluster_name` | `string` | n/a | sim | Nome do cluster ECS. |
| `task_definition_arn` | `string` | n/a | sim | ARN da task definition. |
| `subnets` | `list(string)` | n/a | sim | Subnets do servico. |
| `security_groups` | `list(string)` | n/a | sim | Security groups do servico. |
| `tags` | `map(string)` | n/a | sim | Tags do servico. Deve conter: `owner`, `partner`, `business`, `product`. |
| `container_port` | `number` | `null` | nao | Porta do container no fallback de LB simples. |
| `load_balancers` | `list(object)` | `null` | nao | Lista de LBs com `container_name` (opcional), `container_port`, `target_group_arn`. |
| `target_group_arn` | `string` | `null` | nao | Target group unico (fallback quando `load_balancers` nao e informado). |
| `desire_count` | `number` | `1` | nao | Quantidade desejada de tasks. |
| `assign_public_ip` | `bool` | `true` | nao | Define `assign_public_ip` no servico ECS. |
| `auto_scaling` | `bool` | `false` | nao | Habilita recursos de auto scaling. |
| `min_capacity` | `number` | `1` | nao | Minimo de tasks para auto scaling. |
| `max_capacity` | `number` | `4` | nao | Maximo de tasks para auto scaling. |
| `cpu_target` | `number` | `60` | nao | Alvo de utilizacao de CPU (%). |
| `memory_target` | `number` | `80` | nao | Alvo de utilizacao de memoria (%). |
| `spot_staging` | `bool` | `false` | nao | Ajusta pesos para staging (`FARGATE=1`, `FARGATE_SPOT=2`). |
| `spot` | `bool` | `false` | nao | Habilita capacity providers com Spot. |
| `weight_fargate` | `number` | `2` | nao | Peso do provider `FARGATE` quando `spot=true`. |
| `weight_fargate_spot` | `number` | `1` | nao | Peso do provider `FARGATE_SPOT` quando `spot=true`. |
| `health_check_grace_period_seconds` | `number` | `null` | nao | Define o grace period dos health checks do servico ECS; quando nao informado, o atributo permanece `null`. |

## Observacoes

- Este modulo nao declara `outputs.tf`.
- Nome da variavel: `desire_count` (sem "d"), manter esse nome para compatibilidade.
- Quando `spot = false`, o modulo usa `launch_type = "FARGATE"` e nao usa `capacity_provider_strategy`.
- Quando `spot = true`, o modulo usa `capacity_provider_strategy` e `launch_type = null`.
- `health_check_grace_period_seconds` so e aplicado quando informado; caso contrario, o provider recebe `null`.
