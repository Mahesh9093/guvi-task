terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# ---------- Provider 1: Mumbai (ap-south-1) ----------
provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"
}

# ---------- Provider 2: N. Virginia (us-east-1) ----------
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# ---------- Security Group ----------
resource "aws_security_group" "nginx_sg_mumbai" {
  provider = aws.mumbai
  name        = "nginx-sg-mumbai"
  description = "Allow HTTP and SSH"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg-mumbai"
  }
}

resource "aws_security_group" "nginx_sg_virginia" {
  provider = aws.virginia
  name        = "nginx-sg-virginia"
  description = "Allow HTTP and SSH"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg-virginia"
  }
}

# ---------- EC2 Instances ----------
resource "aws_instance" "nginx_mumbai" {
  provider = aws.mumbai
  ami           = "ami-0f58b397bc5c1f2e8"   # Amazon Linux 2 (ap-south-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.nginx_sg_mumbai.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-mumbai"
  }
}

resource "aws_instance" "nginx_virginia" {
  provider = aws.virginia
  ami           = "ami-0ecb62995f68bb549"   # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.nginx_sg_virginia.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-virginia"
  }
}

# ---------- Output ----------
output "mumbai_public_ip" {
  value = aws_instance.nginx_mumbai.public_ip
}

output "virginia_public_ip" {
  value = aws_instance.nginx_virginia.public_ip
}
