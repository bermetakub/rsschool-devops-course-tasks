resource "aws_instance" "kops_control_plane" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet[sort(keys(aws_subnet.public_subnet))[0]].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  instance_initiated_shutdown_behavior = "stop"
  
  tags = {
    Name = "kops-control-plane"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              yum update -y
              
              # Install necessary packages for kOps
              yum install -y curl git --skip-broken

              # Install kOps
              curl -LO https://github.com/kubernetes/kops/releases/download/v1.28.0/kops-linux-amd64
              chmod +x kops-linux-amd64
              mv kops-linux-amd64 /usr/local/bin/kops

              # Configure AWS CLI (using IAM role or access keys if required)
              aws configure set region us-east-1

              # Create the kOps cluster configuration
              export NAME=bermeta.site
              export KOPS_STATE_STORE=s3://bermeta.terraform.tfstate.bucket
              
              # Initialize kOps cluster setup
              kops create cluster --name $NAME --zones us-east-1 --state $KOPS_STATE_STORE --node-count 2 --node-size t3.small --master-size t3.small --yes
              
              # Apply the configuration
              kops update cluster --name $NAME --state $KOPS_STATE_STORE --yes
              kops validate cluster --name $NAME --state $KOPS_STATE_STORE

              # Create kubeconfig
              mkdir -p /home/ubuntu/.kube
              cp /etc/kubernetes/kops/kops.yaml /home/ubuntu/.kube/config
              chown ubuntu:ubuntu /home/ubuntu/.kube/config
              chmod 644 /home/ubuntu/.kube/config

              # Make kubeconfig accessible without sudo
              echo "export KUBECONFIG=/etc/kubernetes/kops/kops.yaml" >> /etc/profile
              source /etc/profile

              # Install Helm
              curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
              chmod 700 get_helm.sh
              ./get_helm.sh

              # Deploy Jenkins using Helm (example)
              mkdir -p /opt/conf/task_6
              git clone -b task_6 https://github.com/bermetakub/rsschool-devops-course-tasks.git /opt/conf/task_6
              helm install jenkins /opt/conf/task_6/my-app/ -f /opt/conf/task_6/my-app/values.yaml --set jenkins.service.nodePort=32000
              kubectl create secret generic jenkins-kubernetes-credentials --from-file=kubeconfig=/etc/kubernetes/kops/kops.yaml -n jenkins
              EOF
}
