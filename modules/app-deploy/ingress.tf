resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = var.app-name
    namespace = var.namespace
    labels = {
      app = var.app-name
    }

    annotations = var.ingress-annotations != null ? var.ingress-annotations : null
  }

  spec {
    ingress_class_name = var.ingress-class-name

    dynamic "rule" {
      for_each = toset([var.host]) == null ? [] : [var.host]
      content {
        host = rule.value
        http {
          path {
            backend {
              service {
                name = var.app-name
                port {
                  number = 80
                }
              }
            }
            path = var.path
          }
        }
      }
    }
    dynamic "rule" {
      for_each = toset(var.hosts) == null ? [] : var.hosts
      content {
        host = rule.value
        http {
          path {
            backend {
              service {
                name = var.app-name
                port {
                  number = 80
                }
              }
            }
            path = var.path
          }
        }
      }
    }
  }
}
