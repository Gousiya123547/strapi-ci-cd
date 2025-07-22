variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "AWS Key Pair name for SSH access"
  default     = "strapi-kp"  # Replace with your actual key pair name
}

variable "image_tag" {
  description = "Docker image tag for Strapi"
  type        = string
}

