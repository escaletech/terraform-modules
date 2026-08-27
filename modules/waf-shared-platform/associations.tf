resource "aws_wafv2_web_acl_association" "stages" {
  for_each = var.stage_arns

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_association" "albs" {
  for_each = var.alb_arns

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
