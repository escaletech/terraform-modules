resource "kubernetes_ingress" "main" {
  metadata {
    name      = var.app-name
    namespace = var.namespace
    labels = {
      app = var.app-name
    }

    annotations = var.ingress-annotations != null ? var.ingress-annotations : null
  }

  spec {
    ingress_class_name = "nginx"

    dynamic "rule" {
      for_each = toset([var.host]) == null ? [] : [var.host]
      content {
        host = rule.value
        http {
          path {
            backend {
              service_name = var.app-name
              service_port = 80
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
              service_name = var.app-name
              service_port = 80
            }
            path = var.path
          }
        }
      }
    }
  }
}
