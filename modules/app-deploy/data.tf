data "aws_ecr_repository" "repository" {
  count = var.image-fulladdress == null ? 1 : 0
  name  = var.app-name
}
