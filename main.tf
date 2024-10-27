data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "Bermet"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCIDR
  enable_dns_hostnames = true
  tags = {
    "Name" = var.name
  }
}

resource "aws_subnet" "public_subnet" {
  for_each                = { for idx, cidr in var.public_cidrs : cidr => { cidr = cidr, az = element(data.aws_availability_zones.available.names, idx) } }
  availability_zone       = each.value.az
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.name}-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each                = { for idx, cidr in var.private_cidrs : cidr => { cidr = cidr, az = element(data.aws_availability_zones.available.names, idx % length(data.aws_availability_zones.available.names)) } }
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.name}-private-subnet-${each.key}"
  }
}

# Public EC2 instance in one of the public subnets
# resource "aws_instance" "public_instance" {
#   ami                         = var.ami                                                              # Use the appropriate AMI ID (Amazon Machine Image)
#   instance_type               = var.instance_type                                                    # Specify the instance type, e.g., "t2.micro"
#   subnet_id                   = aws_subnet.public_subnet[sort(keys(aws_subnet.public_subnet))[0]].id # Select the first public subnet
#   associate_public_ip_address = true                                                                 # Since this is a public instance
#   key_name                    = var.key_name                                                         # Specify the SSH key to use for access

#   tags = {
#     Name = "${var.name}-public-instance"
#   }

#   # Security group for public instance
#   vpc_security_group_ids = [aws_security_group.public_sg.id]
# }

# Private EC2 instance in one of the private subnets
# resource "aws_instance" "private_instance" {
#   ami                         = var.ami                                                                # Use the appropriate AMI ID
#   instance_type               = var.instance_type                                                      # Specify the instance type
#   subnet_id                   = aws_subnet.private_subnet[sort(keys(aws_subnet.private_subnet))[0]].id # Select the first private subnet
#   associate_public_ip_address = false                                                                  # No public IP for private instance
#   key_name                    = var.key_name                                                           # Specify the SSH key

#   tags = {
#     Name = "${var.name}-private-instance"
#   }

#   # Security group for private instance
#   vpc_security_group_ids = [aws_security_group.private_sg.id]
# }

