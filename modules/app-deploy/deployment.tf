resource "kubernetes_deployment" "main" {
  depends_on = [aws_secretsmanager_secret.secret]
  metadata {
    name      = var.app-name
    namespace = var.namespace
    labels = {
      app = var.app-name
    }
    annotations = local.deployment_annotations
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app-name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app-name
        }
        annotations = local.pod_annotations
      }

      spec {
        container {
          image             = var.image-fulladdress != null ? var.image-fulladdress : "${data.aws_ecr_repository.repository.repository_url}:${var.image-tag}"
          image_pull_policy = var.tags.Environment == "production" ? "IfNotPresent" : "Always"
          name              = var.app-name
          dynamic "env" {
            for_each = var.environments == null ? [] : var.environments
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
          dynamic "env" {
            for_each = var.secrets == null ? [] : var.secrets
            content {
              name = env.value
              value_from {
                secret_key_ref {
                  name = var.app-name
                  key  = env.value
                }
              }
            }
          }

          port {
            container_port = var.port
          }
          dynamic "volume_mount" {
            for_each = var.secrets == null ? [] : [var.secrets]
            content {
              name       = "secrets-store-inline"
              mount_path = "/mnt/secrets-store"
              read_only  = true
            }
          }
          dynamic "resources" {
            for_each = var.resources == null ? [] : [var.resources]
            content {
              limits = {
                cpu    = var.resources.limits.cpu
                memory = var.resources.limits.memory
              }
              requests = {
                cpu    = var.resources.requests.cpu
                memory = var.resources.requests.memory
              }
            }
          }
          dynamic "liveness_probe" {
            for_each = var.liveness == null ? [] : [var.liveness]
            content {
              http_get {
                path = "/healthz"
                port = var.port
              }

              initial_delay_seconds = var.liveness.initial_delay_seconds
              period_seconds        = var.liveness.period_seconds
            }
          }
        }
        dynamic "volume" {
          for_each = var.secrets == null ? [] : [var.secrets]
          content {
            name = "secrets-store-inline"
            csi {
              driver    = "secrets-store.csi.k8s.io"
              read_only = true
              volume_attributes = {
                secretProviderClass = var.app-name
              }
            }
          }
        }
        dynamic "toleration" {
          for_each = var.tolerations == null ? [] : var.tolerations
          content {
            effect   = toleration.value.effect
            key      = toleration.value.key
            operator = toleration.value.operator
          }
        }

        dynamic "affinity" {
          for_each = length(var.node-affinity) > 0 || length(var.pod-affinity) > 0 || length(var.pod-anti-affinity) > 0 ? ["affinity"] : []
          content {
            dynamic "node_affinity" {
              for_each = length(var.node-affinity) > 0 ? ["node_affinity"] : []
              content {
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.node-affinity, "preferred_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value["weight"]
                    preference {
                      dynamic "match_expressions" {
                        for_each = { for v in lookup(preferred_during_scheduling_ignored_during_execution.value["preference"], "match_expressions", []) : uuid() => v }
                        content {
                          key      = match_expressions.value["key"]
                          operator = match_expressions.value["operator"]
                          values   = lookup(match_expressions.value, "values", [])
                        }
                      }
                    }
                  }
                }
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.node-affinity, "required_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    dynamic "node_selector_term" {
                      for_each = { for v in lookup(required_during_scheduling_ignored_during_execution.value, "node_selector_term", []) : uuid() => v }
                      content {
                        dynamic "match_expressions" {
                          for_each = { for v in lookup(node_selector_term.value, "match_expressions", []) : uuid() => v }
                          content {
                            key      = match_expressions.value["key"]
                            operator = match_expressions.value["operator"]
                            values   = lookup(match_expressions.value, "values", [])
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "pod_affinity" {
              for_each = length(var.pod-affinity) > 0 ? ["pod_affinity"] : []
              content {
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.pod-affinity, "preferred_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value["weight"]
                    pod_affinity_term {
                      namespaces   = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"], "namespaces", [])
                      topology_key = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"], "topology_key", "")
                      label_selector {
                        match_labels = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]["label_selector"], "match_labels", {})
                        dynamic "match_expressions" {
                          for_each = { for v in lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]["label_selector"], "match_expressions", []) : uuid() => v }
                          content {
                            key      = match_expressions.value["key"]
                            operator = match_expressions.value["operator"]
                            values   = lookup(match_expressions.value, "values", [])
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.pod-affinity, "required_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    label_selector {
                      match_labels = lookup(required_during_scheduling_ignored_during_execution.value["label_selector"], "match_labels", {})
                      dynamic "match_expressions" {
                        for_each = { for v in lookup(required_during_scheduling_ignored_during_execution.value["label_selector"], "match_expressions", []) : uuid() => v }
                        content {
                          key      = match_expressions.value["key"]
                          operator = match_expressions.value["operator"]
                          values   = lookup(match_expressions.value, "values", [])
                        }
                      }
                    }
                    namespaces   = lookup(required_during_scheduling_ignored_during_execution.value, "namespaces", [])
                    topology_key = lookup(required_during_scheduling_ignored_during_execution.value, "topology_key", "")
                  }
                }
              }
            }

            dynamic "pod_anti_affinity" {
              for_each = length(var.pod-anti-affinity) > 0 ? ["pod_anti_affinity"] : []
              content {
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.pod-anti-affinity, "preferred_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value["weight"]
                    pod_affinity_term {
                      namespaces   = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"], "namespaces", [])
                      topology_key = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"], "topology_key", "")
                      label_selector {
                        match_labels = lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]["label_selector"], "match_labels", {})
                        dynamic "match_expressions" {
                          for_each = { for v in lookup(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]["label_selector"], "match_expressions", []) : uuid() => v }
                          content {
                            key      = match_expressions.value["key"]
                            operator = match_expressions.value["operator"]
                            values   = lookup(match_expressions.value, "values", [])
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = { for v in lookup(var.pod-anti-affinity, "required_during_scheduling_ignored_during_execution", []) : uuid() => v }
                  content {
                    label_selector {
                      match_labels = lookup(required_during_scheduling_ignored_during_execution.value["label_selector"], "match_labels", {})
                      dynamic "match_expressions" {
                        for_each = { for v in lookup(required_during_scheduling_ignored_during_execution.value["label_selector"], "match_expressions", []) : uuid() => v }
                        content {
                          key      = match_expressions.value["key"]
                          operator = match_expressions.value["operator"]
                          values   = lookup(match_expressions.value, "values", [])
                        }
                      }
                    }
                    namespaces   = lookup(required_during_scheduling_ignored_during_execution.value, "namespaces", [])
                    topology_key = lookup(required_during_scheduling_ignored_during_execution.value, "topology_key", "")
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image,
      spec.0.template.0.spec.0.affinity,
      spec.0.template.0.metadata.0.annotations["keel.sh/update-time"],
      metadata.0.resource_version
    ]
  }
}
