provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["-clustername", data.aws_eks_cluster.default.name]
    command     = "./plugin-eks"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["-clustername", data.aws_eks_cluster.default.name]
      command     = "./plugin-eks"
    }
  }
}

module "kube-system" {
  source          = "./kube-system"
  cluster-name    = var.cluster-name
  datadog-enabled = var.datadog-enabled
}
