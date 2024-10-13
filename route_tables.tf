resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public-rt" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public-rt-associate" {
  for_each       = toset(var.public_cidrs)
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public_subnet[each.key].id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NAT.id
}

resource "aws_route_table_association" "private-rt-associate" {
  for_each       = toset(var.private_cidrs)
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private_subnet[each.key].id
}