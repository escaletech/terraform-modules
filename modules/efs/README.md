# Terraform Module - EFS

Modulo Terraform para provisionar um EFS por servico/cliente com:
- Security Group dedicado permitindo NFS (2049) apenas a partir das tasks ECS informadas.
- EFS File System com criptografia habilitada.
- Access Point com usuario POSIX e diretorio raiz inicial.
- Mount Targets em todas as subnets fornecidas.

## Recursos criados
- aws_security_group
- aws_efs_file_system
- aws_efs_access_point
- aws_efs_mount_target

## Requisitos
- Terraform >= 1.3 (recomendado)
- Provider AWS configurado no root module

## Variaveis
| Nome | Tipo | Padrao | Descricao |
| --- | --- | --- | --- |
| service_name | string | n/a | Nome do servico/cliente (ex.: n8n-cliente-abc, n8n-staging) |
| vpc_id | string | n/a | ID da VPC onde criar o EFS |
| subnet_ids | list(string) | n/a | Subnets privadas para criar Mount Targets (minimo 1, ideal 2+) |
| ecs_task_security_group_ids | list(string) | null | Security Groups das tasks ECS que vao acessar o EFS |
| tags | map(string) | {} | Tags para todos os recursos |
| performance_mode | string | generalPurpose | Modo de performance do EFS |
| throughput_mode | string | bursting | Modo de throughput do EFS |
| transition_to_ia | string | AFTER_30_DAYS | Transicao para IA (lifecycle policy) |
| uid | number | 1000 | UID do usuario POSIX do Access Point |
| gid | number | 1000 | GID do usuario POSIX do Access Point |
| root_permissions | string | 0755 | Permissoes do diretorio raiz no Access Point |

## Outputs
| Nome | Descricao |
| --- | --- |
| file_system_id | ID do EFS |
| access_point_id | ID do Access Point |
| security_group_id | Security Group do EFS |

## Exemplo de uso
```hcl
module "efs" {
  source = "./modules/efs"

  service_name                 = "n8n-cliente-abc"
  vpc_id                       = "vpc-1234567890"
  subnet_ids                   = ["subnet-111111", "subnet-222222"]
  ecs_task_security_group_ids  = ["sg-aaaaaa"]

  tags = {
    Environment = "staging"
    Project     = "n8n"
  }
}
```

## Notas
- O Access Point cria o diretorio raiz em `/n8n-data`. Se precisar de outro caminho, ajuste em `main.tf`.
- Para ambientes com alta demanda, ajuste `performance_mode` e `throughput_mode` conforme a necessidade.
