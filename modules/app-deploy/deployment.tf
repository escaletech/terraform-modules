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
          image             = "${data.aws_ecr_repository.repository.repository_url}:${var.image-tag}"
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
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image,
      spec.0.template.0.metadata.0.annotations["keel.sh/update-time"]
    ]
  }
}
