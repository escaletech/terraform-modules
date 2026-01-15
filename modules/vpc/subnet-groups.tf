resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name = var.db_subnet_group_name

  subnet_ids = [
    for key in keys(local.private_subnets) : aws_subnet.this[key].id
  ]

  tags = merge(var.tags, {
    Name = var.db_subnet_group_name
  })
}
