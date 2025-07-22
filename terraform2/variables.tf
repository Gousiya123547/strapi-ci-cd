variable "image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "docker_username" {
  type        = string
  description = "Docker Hub username"
  default     = "gousiyakhan" 
}

variable "aws_region" {
  type        = string
  default     = "us-east-2"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the existing AWS SSH key pair"
  default     = "strapi-kp"
}

