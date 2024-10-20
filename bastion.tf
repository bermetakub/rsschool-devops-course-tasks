resource "aws_instance" "bastion_host" {
  ami             = var.ami # Use appropriate AMI ID
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet["10.0.1.0/24"].id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = "gh"

  tags = {
    Name = "bastion-host"
  }
}