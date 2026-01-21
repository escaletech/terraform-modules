output "lb_arn" {
  description = "ARN of the created load balancer."
  value       = local.create_alb ? aws_lb.alb[0].arn : aws_lb.nlb[0].arn
}

output "lb_dns_name" {
  description = "DNS name of the created load balancer."
  value       = local.create_alb ? aws_lb.alb[0].dns_name : aws_lb.nlb[0].dns_name
}

output "lb_zone_id" {
  description = "Zone ID of the created load balancer."
  value       = local.create_alb ? aws_lb.alb[0].zone_id : aws_lb.nlb[0].zone_id
}

output "security_group_ids" {
  description = "Security group ids attached to the load balancer."
  value       = local.create_alb ? local.alb_security_group_ids : local.nlb_security_group_ids
}
