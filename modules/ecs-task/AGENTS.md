# AGENTS.md

Este arquivo orienta agentes de IA para implementar mudancas neste modulo Terraform com consistencia.

## Objetivo do modulo

Provisionar uma `aws_ecs_task_definition` Fargate com:
- definicao de container simples
- log no CloudWatch via `awslogs`
- suporte a `environment`, `secrets`, `command`, `entrypoint` e `workdir`
- fallback para porta unica ou lista de `port_mappings`
- role IAM da task com policies base e policies adicionais opcionais

## Arquivos principais

- `main.tf`: `aws_ecs_task_definition`, normalizacao de `port_mappings` e montagem de `container_definitions`.
- `variables.tf`: contrato de entrada do modulo.
- `iam.tf`: role IAM da task e anexos de policies.
- `data.tf`: data sources de conta, regiao e policy de logs.
- `output.tf`: saida do ARN da task definition.

## Regras importantes para futuras alteracoes

1. Nao quebrar retrocompatibilidade das variaveis existentes.
2. Preservar o comportamento de fallback de portas:
   - se `port_mappings` estiver informado e tiver itens, usar essa lista
   - senao, se `container_port` existir, gerar um unico `portMappings`
   - senao, nao enviar `portMappings`
3. Preservar o filtro de campos `null` no `container_definitions`.
   Campos opcionais como `command`, `entryPoint` e `workingDirectory` devem ser omitidos do JSON quando nao informados.
4. Manter consistencia dos nomes da API ECS no JSON do container:
   - `entryPoint`
   - `workingDirectory`
   - `portMappings`
5. Se novas variaveis forem adicionadas ao container, atualizar:
   - `variables.tf`
   - `main.tf`
   - `README.md`
6. Manter o mesmo role em `execution_role_arn` e `task_role_arn`, a menos que haja mudanca explicita de desenho.
7. Nao remover a dependencia da policy `ecs_task_cloudwatch_logs_policy` sem ajustar a documentacao e o consumo do modulo.

## Checklist de implementacao

1. Atualizar `variables.tf` para qualquer novo input.
2. Atualizar `main.tf` e/ou `iam.tf` conforme a feature.
3. Atualizar `README.md` com exemplo e tabela de inputs quando houver mudanca de contrato.
4. Validar com:
   - `terraform fmt -check -diff`
   - `terraform validate` (apos `terraform init`, quando provider estiver disponivel)

## Pontos de atencao atuais

- O nome da variavel `environment-variables` usa hifen. Nao renomear sem estrategia de migracao, mesmo nao sendo o padrao mais comum.
- O modulo usa `AmazonElasticContainerRegistryPublicReadOnly`. Se houver necessidade de ECR privado, revisar este anexo com cuidado antes de trocar.
- A policy `ecs_task_cloudwatch_logs_policy` e buscada por nome via data source e precisa existir na conta consumidora.
