data "aws_ssoadmin_instances" "main" {}

resource "aws_ssoadmin_permission_set" "permission_set" {
  name             = var.permission_set_name
  description      = "${var.permission_set_name} group"
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  relay_state      = "https://s3.console.aws.amazon.com/s3/home?region=us-east-1#"
  session_duration = "PT${var.session_duration}H"
}

resource "aws_ssoadmin_managed_policy_attachment" "policy_attachment" {
  for_each = toset(var.attach_policies)

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  permission_set_arn = aws_ssoadmin_permission_set.permission_set.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  count = var.inline_policy != null ? 1 : 0

  inline_policy      = var.inline_policy
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set.arn
}
