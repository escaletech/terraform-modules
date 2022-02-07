resource "kubernetes_cluster_role_binding" "eks-admins-binding" {
  metadata {
    name = "eks-admins-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:sso-eks-admins"
  }
  subject {
    kind      = "Group"
    name      = "system:sso-eks-admins"
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}

resource "kubernetes_cluster_role_binding" "eks-viewers-binding" {
  metadata {
    name = "eks-viewers-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:sso-eks-readonly"
  }
  subject {
    kind      = "Group"
    name      = "system:sso-eks-readonly"
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}

resource "kubernetes_cluster_role_binding" "eks-developers-binding" {
  metadata {
    name = "eks-developers-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:sso-eks-developers"
  }
  subject {
    kind      = "Group"
    name      = "system:sso-eks-developers"
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}
