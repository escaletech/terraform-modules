module "ns-roles" {
  source = "../ns-roles"

  cluster-name = var.cluster-name
  namespaces   = var.namespaces
  tags         = var.tags
}
