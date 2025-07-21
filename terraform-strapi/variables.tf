variable "aws_region" {
  default = "us-east-2" # Ohio
}

variable "ec2_ami" {
  # Amazon Linux 2 AMI for us-east-2 (Ohio)
  default = "ami-0900fe555666598a2"
}

variable "ec2_instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "strapi-kp"
}

