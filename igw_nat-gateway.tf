resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  tags = {
    "Name" = "${var.name}-eip"
  }
}

resource "aws_nat_gateway" "NAT" {
  subnet_id     = aws_subnet.public_subnet[sort(keys(aws_subnet.public_subnet))[0]].id
  allocation_id = aws_eip.eip.id
}