# AGENTS.md

Este arquivo orienta agentes de IA para implementar mudancas neste modulo Terraform com consistencia.

## Objetivo do modulo

Provisionar/atualizar um servico ECS Fargate (`aws_ecs_service`) com suporte a:
- rede (subnets/security groups/public IP)
- load balancer dinamico (1 ou N target groups)
- estrategia de capacidade com `FARGATE` e `FARGATE_SPOT`
- auto scaling opcional por CPU e memoria (`aws_appautoscaling_*`)

## Arquivos principais

- `main.tf`: recurso `aws_ecs_service` e configuracoes de deploy/capacity provider/load balancer.
- `auto-scaling.tf`: alvo e politicas de auto scaling (CPU e memoria), condicionais por `var.auto_scaling`.
- `variables.tf`: contrato de entrada do modulo (tipos, defaults e validacoes).

## Regras importantes para futuras alteracoes

1. Nao quebrar retrocompatibilidade de variaveis existentes.
2. Manter `deployment_circuit_breaker` habilitado com rollback.
3. Preservar logica condicional de `spot`:
   - `spot = false`: usa `launch_type = "FARGATE"` e sem capacity providers.
   - `spot = true`: `launch_type = null` e habilita `capacity_provider_strategy`.
4. Preservar fallback de load balancer:
   - se `load_balancers` for informado, usar lista completa.
   - senao, se `target_group_arn` existir, criar bloco unico com `service_name` e `container_port`.
5. Preservar validacao obrigatoria de tags: `owner`, `partner`, `business`, `product`.
6. Em novas variaveis:
   - adicionar descricao clara
   - definir `type`
   - fornecer `default` quando fizer sentido
7. Se incluir novos recursos AWS, manter naming consistente com `service_name`.

## Checklist de implementacao

1. Atualizar `variables.tf` para qualquer novo input.
2. Atualizar `main.tf` e/ou `auto-scaling.tf` conforme feature.
3. Atualizar `README.md` (inputs, comportamento e exemplo).
4. Validar sintaxe com:
   - `terraform fmt -recursive`
   - `terraform validate`

## Ponto de atencao atual

- A variavel e o atributo usam `desire_count` (sem "d"). Nao renomear sem estrategia de migracao para evitar breaking change.

