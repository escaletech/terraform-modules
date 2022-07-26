locals {
  all_namespaces        = var.namespaces
  ns_to_remove          = var.namespaces-without-roles
  list_with_ns_in_front = distinct(concat(local.ns_to_remove, local.all_namespaces))
  list_excluding_ns     = slice(local.list_with_ns_in_front, length(local.ns_to_remove), length(local.list_with_ns_in_front))
}

module "ns-roles" {
  source = "../ns-roles"

  cluster-name          = var.cluster-name
  namespaces            = var.namespaces
  namespaces-with-roles = local.list_excluding_ns
  tags                  = var.tags
}
