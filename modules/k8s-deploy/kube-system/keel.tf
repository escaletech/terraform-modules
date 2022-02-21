resource "helm_release" "keel" {
  name      = "keel"
  namespace = "kube-system"

  repository = "https://charts.keel.sh"
  chart      = "keel"

  set {
    name  = "podAnnotations\\.ad\\.datadoghq\\.com/keel\\.logs"
    value = "[{\"source\":\"keel\"\\,\"service\":\"keel\"}]"
  }

  set {
    name  = "podAnnotations\\.ad\\.datadoghq\\.com/keel\\.tags"
    value = "{\"environment\":\"production\"\\,\"env\":\"production\"\\,\"service\":\"keel\"}"
  }

  set {
    name  = "helmProvider.enabled"
    value = false
  }
}
