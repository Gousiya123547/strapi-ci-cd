provider "aws" {
  region = var.aws_region
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Use default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group with dynamic name
resource "aws_security_group" "strapi_sg" {
  vpc_id = data.aws_vpc.default.id
  name   = "strapi-sg-${replace(timestamp(), ":", "-")}" # Dynamic unique name

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

  ingress {
    from_port   = 1337
    to_port     = 1337
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
    Name = "strapi-security-group"
  }
}

# EC2 Instance
resource "aws_instance" "strapi" {
  ami                    = "ami-02b8534ff4b424939"  # Amazon Linux 2 (us-east-2)
  instance_type          = var.ec2_instance_type
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name               = var.ssh_key_name

  associate_public_ip_address = true
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "strapi-instance"
  }
}

