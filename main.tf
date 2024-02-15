terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "private_key" {
  value     = tls_private_key.ec2_key.private_key_pem
  sensitive = true
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key-name"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "aws_security_group" "ec2_security_group" {
  name = "ec2_security_group_hw"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "aws_ec2" {
  ami             = "ami-03cceb19496c25679"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ec2_key_pair.key_name
  security_groups = [aws_security_group.ec2_security_group.name]

  user_data = file("${path.module}/install_wordpress.sh")

  tags = {
    Name = "WordpressInstance"
  }
}