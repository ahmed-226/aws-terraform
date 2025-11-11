terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  
  backend "s3" {
    # Configure these values in backend.tfvars or during init
    # terraform init -backend-config="backend.tfvars"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

resource "aws_instance" "lab_public_ec2" {
  ami                         = "ami-0157af9aea2eef346"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.lab_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.lab_sg_ssh_anywhere.id]
  availability_zone           = "${var.aws_region}a"
  key_name                    = var.key_pair_name
  
  tags = {
    Name = "lab_public_ec2"
  }
}

resource "aws_instance" "lab_private_ec2" {
  ami                         = "ami-0157af9aea2eef346"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.lab_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.lab_sg_ssh_3000_vpc.id]
  availability_zone           = "${var.aws_region}a"
  key_name                    = var.key_pair_name
  
  user_data = <<-EOF
              #!/bin/bash
              
              curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
              yum install -y nodejs
              
              cat > /home/ec2-user/server.js << 'ENDOFFILE'
              const http = require('http');
              const hostname = '0.0.0.0';
              const port = 3000;

              const server = http.createServer((req, res) => {
                res.statusCode = 200;
                res.setHeader('Content-Type', 'text/plain');
                res.end('Hello from Private EC2 Instance!\n');
              });

              server.listen(port, hostname, () => {
                console.log('Server running at http://' + hostname + ':' + port + '/');
              });
              ENDOFFILE
              
              chown ec2-user:ec2-user /home/ec2-user/server.js
              
              su - ec2-user -c "cd /home/ec2-user && nohup node server.js > server.log 2>&1 &"
              EOF
  
  tags = {
    Name = "lab_private_ec2"
  }
}

output "bastion_public_ip" {
  description = "Public IP of the bastion EC2"
  value       = aws_instance.lab_public_ec2.public_ip
}

output "app_private_ip" {
  description = "Private IP of the app EC2"
  value       = aws_instance.lab_private_ec2.private_ip
}