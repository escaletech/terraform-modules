output "id" {
  value = aws_api_gateway_rest_api.gateway_api.id
}

output "root_resource_api_id" {
  value = aws_api_gateway_rest_api.gateway_api.root_resource_id
}


output "gateway_api_arn" {
  value = aws_api_gateway_rest_api.gateway_api.arn
}

output "vpc_endpoint_ids" {
  value = local.vpc_endpoint_ids_effective
}

output "vpc_endpoint_security_group_ids" {
  value = local.vpc_endpoint_security_group_ids_effective
}
