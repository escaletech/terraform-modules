resource "kubernetes_namespace" "ingress" {
  metadata {
    annotations = {
      name = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}

module "nginx-controller" {
  source                   = "terraform-iaac/nginx-controller/helm"
  version                  = "2.0.0"
  depends_on               = [kubernetes_namespace.ingress]
  namespace                = "ingress-nginx"
  ingress_class_is_default = var.ingress_class_is_default
  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service.\\beta\\.kubernetes\\.io/aws-load-balancer-subnets"
      value = join("\\, ", var.nlb_subnets)
      type  = "string"
    }
  ]
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.cluster-domain
      http {
        path {
          backend {
            service {
              name = "ingress-nginx-controller"
              port {
                number = 18080
              }
            }
          }

          path = "/nginx_status"
        }
      }
    }
  }
}
