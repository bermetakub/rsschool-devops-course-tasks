resource "aws_vpc" "VPC-bermet" {
  cidr_block = var.vpcCIDR
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.VPC-bermet.id
  cidr_block = var.subnet1_CIDR
}
