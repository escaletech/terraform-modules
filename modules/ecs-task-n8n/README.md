# ecs-task-n8n

Módulo Terraform para criar uma `aws_ecs_task_definition` Fargate do n8n com EFS dedicado e IAM mínimo para execução.

O módulo cria:
- EFS (via submódulo) com Access Point e permissões de usuário.
- `aws_ecs_task_definition` com volume EFS montado em `/home/node`.
- Role de tarefa e anexos de políticas para execução, ECR e Secrets Manager.

## Uso

```hcl
module "ecs_task_n8n" {
  source = "github.com/escaletech/terraform-modules//modules/ecs-task-n8n"

  family = "n8n"
  image  = "n8nio/n8n:latest"

  cpu    = 256
  memory = 512

  environment-variables = [
    { name = "N8N_HOST", value = "n8n.exemplo.com" },
    { name = "N8N_PROTOCOL", value = "https" },
  ]

  secrets = [
    { name = "N8N_ENCRYPTION_KEY", valueFrom = "arn:aws:secretsmanager:...:secret:..." }
  ]

  container_port = 5678

  # OU use port_mappings para múltiplos mapeamentos
  # port_mappings = [
  #   {
  #     container_port = 5678
  #     host_port      = 5678
  #     protocol       = "tcp"
  #     app_protocol   = "http"
  #     name           = "n8n-5678-tcp"
  #   }
  # ]

  arn_attach_additional_policy = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  cpu_architecture = "X86_64"

  vpc_id         = "vpc-xxxxxxxx"
  subnet_ids     = ["subnet-aaaa", "subnet-bbbb"]
  ecs_task_sg_id = "sg-xxxxxxxx"
  tags = {
    Environment = "dev"
    Project     = "n8n"
  }
}
```

## Entradas

| Nome | Tipo | Padrão | Descrição |
|------|------|--------|-----------|
| `family` | `string` | n/a | Nome da tarefa ECS. |
| `image` | `string` | n/a | A imagem do container da tarefa ECS. |
| `environment-variables` | `list(object({ name = string, value = string }))` | `[]` | Variáveis de ambiente da tarefa ECS. |
| `cpu` | `number` | `256` | CPU alocada para a tarefa ECS. |
| `memory` | `number` | `512` | Memória alocada para a tarefa ECS. |
| `container_port` | `number` | `null` | Porta mapeada no container (usado quando `port_mappings` é vazio). |
| `port_mappings` | `list(object({ container_port = number, host_port = optional(number), protocol = optional(string), app_protocol = optional(string), name = optional(string) }))` | `null` | Lista de mapeamentos de portas. Quando fornecida, substitui `container_port`. |
| `protocol` | `string` | `"tcp"` | Protocolo de rede utilizado. |
| `app_protocol` | `string` | `"http"` | Protocolo da aplicação (ex.: `http`). |
| `secrets` | `list(object({ name = string, valueFrom = string }))` | `[]` | Lista de secrets (AWS Secrets Manager / SSM). |
| `arn_attach_additional_policy` | `list(string)` | `[]` | Lista de ARNs de políticas adicionais para anexar ao role da tarefa. |
| `cpu_architecture` | `string` | `"X86_64"` | Arquitetura de CPU para a tarefa ECS. |
| `vpc_id` | `string` | n/a | VPC ID onde o EFS será criado. |
| `subnet_ids` | `list(string)` | n/a | Subnets onde o EFS criará os mount targets. |
| `ecs_task_sg_id` | `string` | n/a | Security Group ID das tasks ECS para permitir acesso ao EFS. |
| `tags` | `map(string)` | `{}` | Tags aplicadas ao EFS. |

## Saídas

| Nome | Descrição |
|------|-----------|
| `task_definition_arn` | ARN da definição de tarefa ECS criada. |

## Observações

- O volume EFS é montado em `/home/node` com `transit_encryption` habilitado e Access Point com IAM.
- A task definition é criada apenas após a criação do EFS, mount targets e access point (`depends_on = [module.efs]`).
- O log group do CloudWatch é criado automaticamente pela task (`awslogs-create-group = "true"`).
- O EFS é criado via submódulo e requer `vpc_id`, `subnet_ids` e `ecs_task_sg_id`.
