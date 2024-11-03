resource "aws_instance" "k3s_master" {
  ami             = "ami-07caf09b362be10b8"
  instance_type   = "t3.small"
  subnet_id       = aws_subnet.public_subnet[sort(keys(aws_subnet.public_subnet))[0]].id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = "mykey"

  tags = {
    Name = "k3s-master"
  }
}

# EC2 Instance for k3s agent (worker node)
resource "aws_instance" "k3s_agent" {
  ami             = "ami-07caf09b362be10b8"
  instance_type   = "t3.small"
  subnet_id       = aws_subnet.public_subnet[sort(keys(aws_subnet.public_subnet))[0]].id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = "mykey"

  tags = {
    Name = "k3s-agent"
  }
}