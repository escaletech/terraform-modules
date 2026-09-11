# modules/tags/main.tf
#
# Este módulo não cria recursos AWS.
# Toda a lógica está em locals (outputs.tf) — o output `tags` é o
# map pronto para ser passado via default_tags no provider ou merge()
# em recursos individuais.
#
# Uso:
#
#   module "standard_tags" {
#     source              = "../../modules/tags"
#     environment         = "Production"
#     partner             = "claro"
#     operation           = "broadband-retention"
#     owner               = "Infra Cloud Team"
#     repository          = "https://github.com/escaletech/infra-claro"
#     criticality         = "High"
#     data_classification = "Confidential"
#   }
#
# As chaves geradas seguem PascalCase (Environment, Partner, ManagedBy...).

terraform {
  required_version = ">= 1.9"
}
