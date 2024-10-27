## This module will create:
VPC
Private and Public Subnets
Security Groups and NACL
Route Tables
Bastion Host
NAT Gateway
NACL
K3s Master and Agent Instances

## Usage
Define your data in terraform.tfvars file:
```terraform

public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
ingress_ports = [22, 80, 443]

## Deploy the infrastructure:

```Run the following commands in the root folder:

terraform init to initialize the Terraform environment.
terraform plan to preview the infrastructure changes.
terraform apply to apply the infrastructure and deploy the resources.
terraform destroy to destroy the infrastructure when no longer needed.

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
bash
curl -sfL https://get.k3s.io | sh -
After the installation, retrieve the K3s token from the master:
bash
sudo cat /var/lib/rancher/k3s/server/node-token
On the K3s Agent:

SSH into the K3s agent instance.
Run the following command to join the K3s cluster:
bash

curl -sfL https://get.k3s.io | K3S_URL=https://<k3s-master-ip>:6443 K3S_TOKEN=<your-node-token> sh -
Replace <k3s-master-ip> with the public IP of the K3s master and <your-node-token> with the token retrieved from the master.

## Requirements
Name	Version
<a name="requirement_terraform"></a> terraform	>= 1.3
<a name="requirement_aws"></a> aws	>= 4.0
## Providers
Name	Version
<a name="provider_aws"></a> aws	5.70.0
## Resources
Name	Type
aws_eip.eip	resource
aws_instance.bastion_host	resource
aws_instance.k3s_master	resource
aws_instance.k3s_agent	resource
aws_internet_gateway.igw	resource
aws_nat_gateway.NAT	resource
aws_route.private-route	resource
aws_route.public-rt	resource
aws_route_table.private-rt	resource
aws_route_table.public-rt	resource
aws_security_group.private_sg	resource
aws_security_group.public_sg	resource
aws_subnet.private_subnet	resource
aws_subnet.public_subnet	resource
aws_vpc.vpc	resource
aws_availability_zones.available	data source
## Inputs
Name	Description	Type	Default	Required
<a name="input_ami"></a> ami	The AMI from which to launch the instance	string	"ami-07caf09b362be10b8"	no
<a name="input_ingress_ports"></a> ingress_ports	The specified ports will be allowed	list(string)	[]	no
<a name="input_instance_type"></a> instance_type	The type of the instance	string	"t2.micro"	no
<a name="input_key_name"></a> key_name	The name of the key pair to use for SSH access	string	"gh"	no
<a name="input_name"></a> name	Name to be used on all the resources as identifier	string	"Bermet"	no
<a name="input_private_cidrs"></a> private_cidrs	A list of private subnets inside the VPC	list	[]	no
<a name="input_public_cidrs"></a> public_cidrs	A list of public subnets inside the VPC	list	[]	no
<a name="input_vpcCIDR"></a> vpcCIDR	The IPv4 CIDR block for the VPC	string	"10.0.0.0/16"	no
<a name="input_vpcid"></a> vpcid	ID of VPC where security group should be created	string	null	no
## Outputs
Name	Description
<a name="output_igw_id"></a> igw_id	The ID of the Internet Gateway
<a name="output_private_subnets"></a> private_subnets	List of IDs of private subnets
<a name="output_public_subnets"></a> public_subnets	List of IDs of public subnets
<a name="output_vpc_id"></a> vpc_id	The ID of the VPC