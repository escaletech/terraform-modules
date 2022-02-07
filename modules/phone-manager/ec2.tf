resource "aws_instance" "instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = data.aws_security_group.sg.*.id
  key_name               = aws_key_pair.key.key_name
  iam_instance_profile   = var.iam_instance_profile
  tags = merge(var.tags, {
    AllowSSH   = "true"
    Inspection = "true"
  })
  user_data = var.user_data

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_key_pair" "key" {
  key_name   = var.public_key.name
  public_key = var.public_key.value
}
