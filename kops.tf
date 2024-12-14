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
              sudo su -
              yum update -y
              yum install -y curl git

              # Установка AWS CLI
              curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              # Настройка AWS CLI с передачей ключей через параметры (или можно использовать IAM роль для EC2)
              aws configure set aws_access_key_id ##
              aws configure set aws_secret_access_key ##
              aws configure set region us-east-1
              aws configure set output json

              # Переменные для Kops
              export NAME=bermeta.site
              export KOPS_STATE_STORE=s3://bermeta.terraform.tfstate.bucket

              # Создание кластера с помощью Kops
              curl -LO https://github.com/kubernetes/kops/releases/download/v1.28.0/kops-linux-amd64
              chmod +x kops-linux-amd64
              mv -f kops-linux-amd64 /usr/local/bin/kops
              
              # Создание, обновление и валидация кластера
              kops create cluster --name $NAME --zones us-east-1a --state $KOPS_STATE_STORE --node-count 2 --node-size t3.small --control-plane-size t3.small --dns public --yes
              kops update cluster --name $NAME --state $KOPS_STATE_STORE --yes
              kops validate cluster --name $NAME --state $KOPS_STATE_STORE
              EOF
}
