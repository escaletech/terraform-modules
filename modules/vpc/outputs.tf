output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.this : k => v.id }
}

output "public_subnet_ids" {
  value = [for k in keys(local.public_subnets) : aws_subnet.this[k].id]
}

output "private_subnet_ids" {
  value = [for k in keys(local.private_subnets) : aws_subnet.this[k].id]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  value = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "db_subnet_group_name" {
  value = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : null
}
