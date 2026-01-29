# Módulo Load Balancer Target e Listener Rule

Este módulo Terraform cria um Target Group (Grupo de Destino) para um Application Load Balancer (ALB), um anexo de destino e uma Listener Rule (Regra do Receptor).

## Uso

Para usar este módulo, inclua-o em seu código Terraform e forneça as variáveis necessárias.

### Exemplo

```terraform
module "meu_app_target" {
  source = "github.com/escaletech/terraform-modules/modules/loadbalancer-target-listener"

  listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/meu-load-balancer/..."
  vpc_id       = "vpc-0123456789abcdef0"
  target_name  = "meu-app-target"
  target_port  = 80

  # Condições para a regra
  host_header = ["app.example.com"]
}
```

## Variáveis de Entrada

Consulte `variable.tf` para obter a lista completa de variáveis de entrada e suas descrições.

## Saídas

Consulte `outputs.tf` para obter a lista completa de saídas e suas descrições.

## Observações Importantes

*   **VPC ID Fixo**: O recurso `aws_lb_target_group` atualmente usa uma fonte de dados (`data.aws_vpc.escale-prod.id`) para o ID da VPC em vez de usar a variável `vpc_id` fornecida.
*   **Listener Rule Quebrada**: O recurso `aws_lb_listener_rule` em `listener.tf` contém referências a recursos que não existem no módulo, o que causará um erro. O código precisará ser corrigido para que o módulo funcione como esperado.
