resource "kubernetes_ingress_v1" "private" {
  count = var.host-private != null ? 1 : 0
  metadata {
    name      = var.app-name
    namespace = var.namespace
    labels = {
      app = var.app-name
    }
  }

  spec {
    ingress_class_name = var.ingress-class-name-private

    dynamic "rule" {
      for_each = toset([var.host-private]) == null ? [] : [var.host-private]
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
