# resource "aws_instance" "bastion" {
#   ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
#   instance_type = "t3.small"
#   subnet_id     = aws_subnet.public.id
#   key_name      = var.key_name

#   tags = {
#     Name = "BastionHost"
#   }
# }