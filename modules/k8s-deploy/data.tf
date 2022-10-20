data "aws_eks_cluster" "default" {
  name = var.cluster-name
}

data "aws_iam_role" "nodes" {
  name = var.cluster-role-nodes
}
