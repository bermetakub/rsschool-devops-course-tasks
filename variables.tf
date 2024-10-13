variable "vpcCIDR" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "Bermet"
}

variable "public_cidrs" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_cidrs" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "vpcid" {
  description = "ID of VPC where security group should be created"
  type        = string
  default     = null
}

variable "ingress_ports" {
  description = "The specified ports will be allowed"
  type        = list(string)
  default     = []

}

variable "ami" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = "ami-07caf09b362be10b8"
}


variable "instance_type" {
  description = "The type of the instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  default     = "gh"
}
