# AWS AppConfig Module

Este módulo Terraform cria e gerencia recursos do AWS AppConfig, incluindo aplicação, ambiente, perfil de configuração, versão da configuração hospedada, estratégia de implantação e a implantação da configuração.

## Uso

Para usar este módulo, inclua-o em seu código Terraform e forneça os valores necessários para as variáveis.

### Exemplo

```terraform
module "my_app_config" {
  source = "github.com/escaletech/terraform-modules/modules/appconfig"

  app_name        = "name-project"
  app_description = "name project application configuration"
  env_name        = "staging"
  
  config_content = jsonencode({
    TEST = "test-value"
  })

  tags = {
    Terraform = "true"
  }
}
```

## Variáveis de Entrada

Consulte `variables.tf` para obter a lista completa de variáveis de entrada e suas descrições.

## Saídas

Consulte `outputs.tf` para obter a lista completa de saídas e suas descrições.
