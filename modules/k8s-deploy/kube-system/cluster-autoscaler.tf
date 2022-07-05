resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  version    = "9.19.2"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster-name
  }

  set {
    name  = "fullnameOverride"
    value = "cluster-autoscaler"
  }
}
