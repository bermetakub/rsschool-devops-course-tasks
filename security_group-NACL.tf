resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(var.ingress_ports)
    content {
      to_port     = ingress.key
      from_port   = ingress.key
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.name}-public-sg"
  }
}

# Security group for the private instance (Allowing SSH access from the public instance)
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.public_subnet : subnet.cidr_block] # Allow SSH from the public subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.name}-private-sg"
  }
}

# Create the NACL
resource "aws_network_acl" "main_nacl" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Main NACL"
  }
}

# Inbound rule to allow HTTP traffic
resource "aws_network_acl_rule" "inbound_http" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Inbound rule to allow HTTPS traffic
resource "aws_network_acl_rule" "inbound_https" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Inbound rule to allow SSH traffic (only from the public subnet to the private subnet)
resource "aws_network_acl_rule" "inbound_ssh1" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Loop over all public subnets # Restrict SSH access from the public subnet
  from_port      = 22
  to_port        = 22
}

# Outbound rule to allow all traffic
resource "aws_network_acl_rule" "outbound_all" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1" # -1 for all protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Public subnet association with NACL
resource "aws_network_acl_association" "public_nacl_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.main_nacl.id
}

# Private subnet association with NACL
resource "aws_network_acl_association" "private_nacl_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.main_nacl.id
}
