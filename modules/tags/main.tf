# modules/tags/main.tf
#
# Este módulo não cria recursos AWS.
# Toda a lógica está em locals (outputs.tf) — o output `tags` é o
# map pronto para ser passado via default_tags no provider ou merge()
# em recursos individuais.
#
# Uso:
#
#   module "tags" {
#     source           = "../../modules/tags"
#     env              = "production"
#     business_partner = "claro"
#     operation        = "broadband-retention"
#     vertical         = "telecom"
#     team             = "platform"
#     repository       = "github.com/escale-ai/infra-claro"
#     backup           = "daily-7d"
#     data_scope       = "non-pii"
#   }

terraform {
  required_version = ">= 1.5"
}
