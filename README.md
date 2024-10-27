## This module will create:
- _VPC_
- _Private and Public Subnets_
- _Security Groups and NACL_
- _Route Tables_
- _Bastion Host_
- _NAT Gateway_
- _NACL_
- _K3s Master and Agent Instances_

## Usage
Define your data in terraform.tfvars file:
```terraform

public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
ingress_ports = [22, 80, 443]

```

## Deploy the infrastructure:

```Run the following commands in the root folder:

- `terraform init` terraform initialization
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply infrastructure build
- `terraform destroy` to destroy the infrastructure

## New K3s Setup
In addition to the VPC, subnets, and security groups, this module now includes two EC2 instances for a K3s master and an agent (worker node).

```K3s Master Node:

The K3s master instance is created with the following configuration:
AMI: ami-07caf09b362be10b8
Instance type: t2.micro
Located in the public subnet
Security groups: Public security group

```K3s Agent Node:

The K3s agent (worker node) is created with similar configuration:
AMI: ami-07caf09b362be10b8
Instance type: t2.micro
Located in the public subnet
Security groups: Public security group
To Connect the Agent to the Master:
After deploying the infrastructure, follow these steps to set up K3s:

On the K3s Master:

SSH into the K3s master instance using the provided key pair.
Run the following command to install K3s as a master:

- `curl -sfL https://get.k3s.io | sh - `
After the installation, retrieve the K3s token from the master:

- `sudo cat /var/lib/rancher/k3s/server/node-token`
On the K3s Agent:

SSH into the K3s agent instance.
Run the following command to join the K3s cluster:

- `curl -sfL https://get.k3s.io | K3S_URL=https://<k3s-master-ip>:6443 K3S_TOKEN=<your-node-token> sh - `
Replace <k3s-master-ip> with the public IP of the K3s master and <your-node-token> with the token retrieved from the master.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 4.0 |

## Providers
| Name | Version |
|------|---------|
| provider_aws |	5.70.0 |

# Resources
| Name                         | Type       |
|------------------------------|------------|
| aws_eip.eip                  | resource   |
| aws_instance.bastion_host    | resource   |
| aws_instance.k3s_master      | resource   |
| aws_instance.k3s_agent       | resource   |
| aws_internet_gateway.igw     | resource   |
| aws_nat_gateway.NAT          | resource   |
| aws_route.private-route      | resource   |
| aws_route.public-rt          | resource   |
| aws_route_table.private-rt   | resource   |
| aws_route_table.public-rt    | resource   |
| aws_security_group.private_sg | resource   |
| aws_security_group.public_sg  | resource   |
| aws_subnet.private_subnet     | resource   |
| aws_subnet.public_subnet      | resource   |
| aws_vpc.vpc                  | resource   |
| aws_availability_zones.available | data source |

# Inputs
| Name                           | Description                                     | Type        | Default                           | Required |
|--------------------------------|-------------------------------------------------|-------------|-----------------------------------|----------|
| ami                            | The AMI from which to launch the instance      | string      | "ami-07caf09b362be10b8"          | no       |
| ingress_ports                  | The specified ports will be allowed             | list(string)| []                                | no       |
| instance_type                  | The type of the instance                        | string      | "t2.micro"                        | no       |
| key_name                       | The name of the key pair to use for SSH access  | string      | "gh"                              | no       |
| name                           | Name to be used on all the resources as identifier | string    | "Bermet"                          | no       |
| private_cidrs                  | A list of private subnets inside the VPC       | list       | []                                | no       |
| public_cidrs                   | A list of public subnets inside the VPC        | list       | []                                | no       |
| vpcCIDR                       | The IPv4 CIDR block for the VPC                | string      | "10.0.0.0/16"                    | no       |
| vpcid                          | ID of VPC where security group should be created | string    | null                              | no       |

# Outputs
| Name                          | Description                                     |
|-------------------------------|-------------------------------------------------|
| igw_id                        | The ID of the Internet Gateway                  |
| private_subnets               | List of IDs of private subnets                  |
| public_subnets                | List of IDs of public subnets                   |
| vpc_id                        | The ID of the VPC                              |
