# ecs-task

Modulo Terraform para criar uma `aws_ecs_task_definition` Fargate com configuracao simples de container, logs no CloudWatch, secrets e mapeamento de portas.

O modulo cria:
- `aws_ecs_task_definition.task_definition`
- `aws_iam_role.ecs_task_role`
- anexos de politica para execucao de task, ECR publico, Secrets Manager e logs

## Requisitos

- Terraform compativel com uso de `optional(...)` em tipos de objeto.
- Provider AWS configurado no projeto consumidor.
- Policy `ecs_task_cloudwatch_logs_policy` existente na conta.

## Uso basico

```hcl
module "ecs_task" {
  source = "./modules/ecs-task"

  family = "my-app"
  image  = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:1.0.0"

  cpu    = 256
  memory = 512

  environment-variables = [
    { name = "APP_ENV", value = "production" },
    { name = "LOG_LEVEL", value = "info" }
  ]

  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:secretsmanager:us-west-2:123456789012:secret:database-url"
    }
  ]

  container_port = 8080
}
```

## Uso com `command`, `entrypoint` e `workdir`

```hcl
module "ecs_task" {
  source = "./modules/ecs-task"

  family = "worker"
  image  = "123456789012.dkr.ecr.us-west-2.amazonaws.com/worker:1.0.0"

  command    = ["bundle", "exec", "sidekiq"]
  entrypoint = ["/bin/sh", "-lc"]
  workdir    = "/app"

  cpu    = 512
  memory = 1024
}
```

## Uso com multiplos `port_mappings`

```hcl
module "ecs_task" {
  source = "./modules/ecs-task"

  family = "api"
  image  = "123456789012.dkr.ecr.us-west-2.amazonaws.com/api:1.0.0"

  port_mappings = [
    {
      container_port = 8080
      host_port      = 8080
      protocol       = "tcp"
      app_protocol   = "http"
      name           = "api-http"
    },
    {
      container_port = 9090
      protocol       = "tcp"
      name           = "api-metrics"
    }
  ]
}
```

## Entradas

| Nome | Tipo | Padrao | Obrigatorio | Descricao |
|---|---|---|---|---|
| `family` | `string` | n/a | sim | Nome da task ECS. |
| `image` | `string` | n/a | sim | Imagem do container. |
| `environment-variables` | `list(object({ name = string, value = string }))` | `[]` | nao | Variaveis de ambiente do container. |
| `command` | `list(string)` | `null` | nao | Comando a ser executado no container. |
| `entrypoint` | `list(string)` | `null` | nao | Entrypoint do container. |
| `workdir` | `string` | `null` | nao | Diretorio de trabalho do container. |
| `cpu` | `number` | `256` | nao | CPU alocada para a task. |
| `memory` | `number` | `512` | nao | Memoria alocada para a task. |
| `container_port` | `number` | `null` | nao | Porta unica do container. Usada como fallback quando `port_mappings` nao for informado. |
| `port_mappings` | `list(object({ container_port = number, host_port = optional(number), protocol = optional(string), app_protocol = optional(string), name = optional(string) }))` | `null` | nao | Lista de mapeamentos de porta. Quando informada, substitui o fallback de `container_port`. |
| `protocol` | `string` | `"tcp"` | nao | Protocolo de rede usado no fallback de `container_port`. |
| `app_protocol` | `string` | `"http"` | nao | Protocolo de aplicacao usado no fallback de `container_port`. |
| `secrets` | `list(object({ name = string, valueFrom = string }))` | `[]` | nao | Lista de secrets do container. |
| `arn_attach_additional_policy` | `list(string)` | `[]` | nao | ARNs de policies adicionais para anexar ao role da task. |
| `cpu_architecture` | `string` | `"X86_64"` | nao | Arquitetura da CPU da task. |

## Saidas

| Nome | Descricao |
|---|---|
| `task_definition_arn` | ARN da definicao de task criada. |

## Observacoes

- O modulo cria uma task definition Fargate com `network_mode = "awsvpc"` e `operating_system_family = "LINUX"`.
- `command`, `entrypoint` e `workdir` sao opcionais. Quando o valor e `null`, a chave nao e enviada no `container_definitions`.
- Se `port_mappings` estiver vazio ou `null`, o modulo tenta montar um unico mapeamento a partir de `container_port`.
- Se `host_port` nao for informado em `port_mappings`, o modulo usa o valor de `container_port`.
- O log group e criado automaticamente pelo driver `awslogs` com `awslogs-create-group = "true"`.
- O mesmo role e usado em `execution_role_arn` e `task_role_arn`.

