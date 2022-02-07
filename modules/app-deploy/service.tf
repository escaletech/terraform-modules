resource "kubernetes_service" "main" {
  metadata {
    name      = var.app-name
    namespace = var.namespace
    labels = {
      "app" = var.app-name
    }
  }
  spec {
    selector = {
      app = var.app-name
    }
    port {
      port        = 80
      target_port = var.port
    }
  }
}
