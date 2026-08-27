resource "aws_cloudwatch_metric_alarm" "blocked_requests" {
  alarm_name          = "${local.name}-BlockedRequests"
  alarm_description   = "WAFv2 ${local.name} BlockedRequests (Rule=ALL). No v1 o block esperado e IP Reputation."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.alarm_blocked_requests_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions
  tags                = local.tags

  dimensions = {
    WebACL = local.name
    Region = local.aws_region
    Rule   = "ALL"
  }
}
