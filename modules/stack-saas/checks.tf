# Avisos de deprecacao do esquema de tags.
#
# Blocos `check` emitem WARNING no plan/apply sem bloquear a execucao.
# A validacao dura (erro) esta em variable.tf e aceita tanto o esquema
# legado quanto o canonico; aqui apenas sinalizamos quem ainda nao migrou.
# Na v2.0.0 o esquema legado deixa de ser aceito.

locals {
  standard_tag_keys = ["Environment", "Partner", "Operation", "Owner", "ManagedBy", "Repository"]
  missing_tag_keys  = [for k in local.standard_tag_keys : k if !contains(keys(var.tags), k)]
  non_pascal_keys   = [for k in keys(var.tags) : k if !can(regex("^[A-Z][A-Za-z0-9]*$", k))]
}

check "tags_standard_schema" {
  assert {
    condition     = length(local.missing_tag_keys) == 0
    error_message = "[DEPRECATION] stack-saas: tags fora do padrao — faltam ${join(", ", local.missing_tag_keys)}. Migre para module.standard_tags.tags (modules/tags). Isso passara a ser obrigatorio na v2.0.0."
  }
}

check "tags_pascal_case" {
  assert {
    condition     = length(local.non_pascal_keys) == 0
    error_message = "[DEPRECATION] stack-saas: chaves de tag fora do PascalCase: ${join(", ", local.non_pascal_keys)}. Tags na AWS sao case-sensitive; 'Partner' e 'partner' viram tags distintas no Cost Explorer. Isso passara a ser obrigatorio na v2.0.0."
  }
}
