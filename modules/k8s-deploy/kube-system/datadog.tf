resource "helm_release" "datadog_agent" {
  count      = var.datadog-enabled != true ? 0 : 1
  name       = "datadog-agent"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "2.22.6"
  namespace  = "kube-system"

  set_sensitive {
    name  = "datadog.apiKey"
    value = jsondecode(data.aws_secretsmanager_secret_version.api-key-datadog-version[count.index].secret_string)["datadog-api-key"]
  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = false
  }

  set {
    name  = "datadog.leaderElection"
    value = true
  }

  set {
    name  = "datadog.collectEvents"
    value = true
  }

  set {
    name  = "clusterAgent.enabled"
    value = true
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = true
  }

  set {
    name  = "networkMonitoring.enabled"
    value = true
  }

  set {
    name  = "systemProbe.enableTCPQueueLength"
    value = true
  }

  set {
    name  = "systemProbe.enableOOMKill"
    value = true
  }

  set {
    name  = "securityAgent.runtime.enabled"
    value = true
  }

  set {
    name  = "datadog.hostVolumeMountPropagation"
    value = "HostToContainer"
  }

  set {
    name  = "datadog.containerExcludeLogs"
    value = "kube_namespace:.*"
  }

  set {
    name  = "datadog.containerIncludeLogs"
    value = "kube_namespace:lead-data-platform kube_namespace:lead-platform kube_namespace:finance-bv kube_namespace:zelas-saude kube_namespace:escale-os-bff kube_namespace:finance-qista kube_namespace:finance-itau"
  }

  values = [
    file("${path.module}/datadog-files/values.yaml")
  ]
}
