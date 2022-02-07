locals {
  topic_name = join("-", [var.name, "topic", var.environment])
}

resource "aws_sns_topic" "sns_topic" {
  name = local.topic_name
  tags = var.tags
}

data "aws_iam_policy_document" "sns_topic" {
  count = var.role_name != null ? 1 : 0

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
      "SNS:Receive"
    ]

    resources = [
      aws_sns_topic.sns_topic.arn,
    ]
  }
}

resource "aws_iam_policy" "sns_topic" {
  count = var.role_name != null ? 1 : 0
  name  = aws_sns_topic.sns_topic.name

  policy = data.aws_iam_policy_document.sns_topic[0].json
}

resource "aws_iam_role_policy_attachment" "sns_topic" {
  count = var.role_name != null ? 1 : 0

  role       = var.role_name
  policy_arn = aws_iam_policy.sns_topic[0].arn
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  for_each = var.topic_subscriptions

  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
