Here is a README.md file for the pipeline and the Terraform module you provided:

---

# Jenkins Pipeline for Prometheus Deployment on Kubernetes

This repository contains a Jenkins pipeline that automates the deployment of Prometheus using Helm in a Kubernetes cluster, along with an associated Terraform module for creating AWS infrastructure (VPC, subnets, security groups, and EC2 instances for K3s).

## Jenkins Pipeline Overview

The pipeline automates the following steps:

1. **Prepare Kubernetes Environment**: Adds the Prometheus Helm chart repository and updates the local Helm repository cache.
2. **Deploy Prometheus with Helm**: Deploys Prometheus using the Helm `kube-prometheus-stack` chart, specifying values from `values.yaml`.
3. **Validate Prometheus Deployment**: Checks that the Prometheus pods are running in the `monitoring` namespace.

### Pipeline Configuration

```groovy
pipeline {
    agent {
        kubernetes {
            label 'prometheus-deploy'
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: jenkins-agent
    image: jenkins/inbound-agent:latest
    command:
    - cat
    tty: true
  - name: helm
    image: alpine/helm:3.11.1
    command: ['cat']
    tty: true
"""
        }
    }
    environment {
        AWS_CREDENTIALS_ID = 'aws-ecr'
        AWS_REGION = 'us-east-1'
        KUBE_NAMESPACE = 'monitoring'
        HELM_RELEASE_NAME = 'prometheus'
        HELM_CHART_REPO = 'https://prometheus-community.github.io/helm-charts'
        HELM_CHART_NAME = 'kube-prometheus-stack'
    }
    stages {
        stage('Prepare Kubernetes Environment') {
            steps {
                container('helm') {
                    sh """
                    helm repo add prometheus-community ${HELM_CHART_REPO}
                    helm repo update
                    """
                }
            }
        }
        stage('Deploy Prometheus with Helm') {
            steps {
                container('helm') {
                    sh """
                    helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_NAME} \\
                        --namespace ${KUBE_NAMESPACE} \\
                        --create-namespace \\
                        -f ./values.yaml
                    """
                }
            }
        }
        stage('Validate Prometheus Deployment') {
            steps {
                container('helm') {
                    sh "kubectl get pods -n ${KUBE_NAMESPACE}"
                }
            }
        }
    }
    post {
        always {
            cleanWs()
            mail to: 'alymkulovabk@gmail.com',
            subject: "Jenkins Build: ${currentBuild.result}",
            body: "Job: ${env.JOB_NAME} \n Build Number: ${env.BUILD_NUMBER}"
        }
    }
}
```

### Pipeline Stages

1. **Prepare Kubernetes Environment**:
   - Adds the Prometheus Helm chart repository and updates the Helm local cache.
   
2. **Deploy Prometheus with Helm**:
   - Installs or upgrades the Prometheus Helm chart in the specified namespace with the configuration from `values.yaml`.

3. **Validate Prometheus Deployment**:
   - Verifies that Prometheus and related services are running by listing the pods in the `monitoring` namespace.

### Post-build Actions

After the build completes, a clean-up of the workspace is performed, and a notification is sent via email about the build's status.

---

## Terraform Module for AWS Infrastructure

This module provisions the required AWS infrastructure for running K3s, including the VPC, subnets, security groups, and EC2 instances for the master and agent nodes.

### Infrastructure Components

- **VPC**: A virtual private cloud is created to house the resources.
- **Private and Public Subnets**: Subnets for segregating different resources.
- **Security Groups and NACLs**: Controls access to resources based on network traffic.
- **Route Tables**: Ensures proper routing between the public and private subnets.
- **Bastion Host**: Provides a secure entry point to the private network.
- **NAT Gateway**: Enables internet access for private subnet resources.
- **K3s Master and Agent Instances**: EC2 instances set up for running K3s.

### Usage

Define the variables in your `terraform.tfvars` file:

```terraform
public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
ingress_ports = [22, 80, 443]
```

### Deploy the Infrastructure

Run the following commands in the root folder:

- `terraform init` - Initializes Terraform and downloads the necessary providers.
- `terraform plan` - Displays the changes Terraform will make.
- `terraform apply` - Applies the Terraform configuration and creates the infrastructure.
- `terraform destroy` - Destroys the resources created by Terraform.

### New K3s Setup

This module now includes EC2 instances for K3s master and agent (worker node).

#### K3s Master Node

- **AMI**: `ami-07caf09b362be10b8`
- **Instance Type**: `t2.micro`
- **Location**: Public Subnet
- **Security Groups**: Public Security Group

#### K3s Agent Node

- **AMI**: `ami-07caf09b362be10b8`
- **Instance Type**: `t2.micro`
- **Location**: Public Subnet
- **Security Groups**: Public Security Group

#### Setting Up K3s

1. **On the K3s Master Node**:
   - SSH into the K3s master.
   - Install K3s as the master: 
     ```bash
     curl -sfL https://get.k3s.io | sh -
     ```
   - Retrieve the K3s token:
     ```bash
     sudo cat /var/lib/rancher/k3s/server/node-token
     ```

2. **On the K3s Agent Node**:
   - SSH into the K3s agent.
   - Join the K3s cluster:
     ```bash
     curl -sfL https://get.k3s.io | K3S_URL=https://<k3s-master-ip>:6443 K3S_TOKEN=<your-node-token> sh -
     ```

### Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3   |
| aws       | >= 4.0   |

### Providers

| Name          | Version   |
|---------------|-----------|
| provider_aws  | 5.70.0    |

### Resources

| Name                                | Type        |
|-------------------------------------|-------------|
| aws_eip.eip                         | resource    |
| aws_instance.bastion_host           | resource    |
| aws_instance.k3s_master             | resource    |
| aws_instance.k3s_agent              | resource    |
| aws_internet_gateway.igw           | resource    |
| aws_nat_gateway.NAT                 | resource    |
| aws_route.private-route             | resource    |
| aws_route.public-rt                 | resource    |
| aws_route_table.private-rt          | resource    |
| aws_route_table.public-rt           | resource    |
| aws_security_group.private_sg       | resource    |
| aws_security_group.public_sg        | resource    |
| aws_subnet.private_subnet           | resource    |
| aws_subnet.public_subnet            | resource    |
| aws_vpc.vpc                          | resource    |
| aws_availability_zones.available    | data source |

### Inputs

| Name             | Description                                          | Type         | Default                    | Required |
|------------------|------------------------------------------------------|--------------|----------------------------|----------|
| ami              | The AMI from which to launch the instance           | string       | "ami-07caf09b362be10b8"     | no       |
| ingress_ports    | The specified ports will be allowed                 | list(string) | []                         | no       |
| instance_type    | The type of the instance                            | string       | "t2.micro"                 | no       |
| key_name         | The name of the key pair for SSH access             | string       | "gh"                       | no       |
| name             | Name to be used on all resources                    | string       | "Bermet"                   | no       |
| private_cidrs    | A list of private subnets inside the VPC            | list         | []                         | no       |
| public_cidrs     | A list of public subnets inside the VPC             | list         | []                         | no       |
| vpcCIDR          | The IPv4 CIDR block for the VPC                     | string       | "10.0.0.0/16"              | no       |
| vpcid            | ID of VPC where security group should be created    | string       | null                       | no       |

### Outputs

| Name              | Description                                        |
|-------------------|----------------------------------------------------|
| igw_id            | The ID of the Internet Gateway                     |
| private_subnets   | List of IDs of private subnets                     |
| public_subnets    | List of IDs of public subnets                      |
| vpc_id            | The ID of the VPC                                  |

---

This README provides a complete guide to the Jenkins pipeline setup and the infrastructure provisioning via Terraform.