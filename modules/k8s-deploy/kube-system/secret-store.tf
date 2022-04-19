resource "helm_release" "secret-store" {
  name      = "secrets-store"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"

  set {
    name  = "syncSecret.enabled"
    value = true
  }

  set {
    name  = "enableSecretRotation"
    value = true
  }

  values = [
    file("${path.module}/secret-store-values.yaml")
  ]
}

resource "kubernetes_service_account" "csi-aws" {
  metadata {
    name      = "csi-secrets-store-provider-aws"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "csi-aws" {
  metadata {
    name = "csi-secrets-store-provider-aws-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts/token"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "csi-aws" {
  metadata {
    name = "csi-secrets-store-provider-aws-cluster-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "csi-secrets-store-provider-aws-cluster-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "csi-secrets-store-provider-aws"
    namespace = "kube-system"
  }
}

resource "kubernetes_daemonset" "csi-aws" {
  metadata {
    name      = "csi-secrets-store-provider-aws"
    namespace = "kube-system"
    labels = {
      app = "csi-secrets-store-provider-aws"
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        app = "csi-secrets-store-provider-aws"
      }
    }

    template {
      metadata {
        labels = {
          app = "csi-secrets-store-provider-aws"
        }
      }

      spec {
        service_account_name = "csi-secrets-store-provider-aws"
        host_network         = true
        toleration {
          key      = "NoScheduleNode"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        container {
          name              = "provider-aws-installer"
          image             = "public.ecr.aws/aws-secrets-manager/secrets-store-csi-driver-provider-aws:1.0.r2-2021.08.13.20.34-linux-amd64"
          image_pull_policy = "Always"
          args = [
            "--provider-volume=/etc/kubernetes/secrets-store-csi-providers"
          ]

          resources {
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "50m"
              memory = "100Mi"
            }
          }

          volume_mount {
            mount_path = "/etc/kubernetes/secrets-store-csi-providers"
            name       = "providervol"
          }

          volume_mount {
            name              = "mountpoint-dir"
            mount_path        = "/var/lib/kubelet/pods"
            mount_propagation = "HostToContainer"
          }
        }

        volume {
          name = "providervol"
          host_path {
            path = "/etc/kubernetes/secrets-store-csi-providers"
          }
        }

        volume {
          name = "mountpoint-dir"
          host_path {
            path = "/var/lib/kubelet/pods"
            type = "DirectoryOrCreate"
          }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}
