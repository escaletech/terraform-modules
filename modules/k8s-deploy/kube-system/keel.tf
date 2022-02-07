resource "helm_release" "keel" {
  name      = "keel"
  namespace = "kube-system"

  repository = "https://charts.keel.sh"
  chart      = "keel"

  set {
    name  = "helmProvider.enabled"
    value = false
  }
}
