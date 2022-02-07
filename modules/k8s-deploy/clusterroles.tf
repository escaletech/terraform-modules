resource "kubernetes_cluster_role" "sso-eks-admins" {
  metadata {
    name = "system:sso-eks-admins"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role" "sso-eks-readonly" {
  metadata {
    name = "system:sso-eks-readonly"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "sso-eks-developers" {
  metadata {
    name = "system:sso-eks-developers"
  }

  rule {
    api_groups = ["*"]
    resources  = ["services", "deployments", "pods", "configmaps", "ingresses", "secrets", "cronjobs", "jobs"]
    verbs      = ["get", "list", "watch", "update", "create", "patch", "delete"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}
