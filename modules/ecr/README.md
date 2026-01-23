# Módulo Terraform para AWS ECR

Este módulo Terraform cria e gerencia um repositório Amazon ECR (Elastic Container Registry) com boas práticas de segurança e gerenciamento.

## Funcionalidades

*   **Imutabilidade de Tags**: Configurado para `IMMUTABLE`, o que impede a sobrescrita de tags de imagem, garantindo a rastreabilidade.
*   **Scan de Segurança**: Ativa o `scan_on_push`, para que cada nova imagem seja automaticamente verificada em busca de vulnerabilidades.
*   **Política de Ciclo de Vida**: Inclui uma política padrão para limpar imagens antigas, o que ajuda a gerenciar custos e a manter o repositório organizado. A política padrão:
    *   Expira imagens **não tagueadas** após 14 dias.
    *   Mantém apenas as 10 imagens mais recentes com tags que começam com `v`.

## Uso

Para usar este módulo, inclua-o em seu código Terraform e forneça um nome para o repositório.

### Exemplo

```terraform
module "meu_app_ecr" {
  source = "github.com/escaletech/terraform-modules/modules/ecr"

  name = "nome-da-minha-aplicacao"

  tags = {
    Projeto     = "Meu App"
    Ambiente    = "Producao"
    Terraform   = "true"
  }
}
```

## Variáveis de Entrada

Consulte `variables.tf` para obter a lista completa de variáveis de entrada e suas descrições. É possível, por exemplo, sobrescrever a política de ciclo de vida padrão passando uma nova pela variável `lifecycle_policy`.

## Saídas

Consulte `outputs.tf` para obter a lista completa de saídas e suas descrições. As principais saídas são o ARN (`repository_arn`) e a URL (`repository_url`) do repositório.
