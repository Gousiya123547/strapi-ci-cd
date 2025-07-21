#!/bin/bash
# Update packages and install Docker
yum update -y
amazon-linux-extras install docker -y
service docker start
systemctl enable docker

# Add ec2-user to Docker group
usermod -aG docker ec2-user

# Wait a bit to ensure Docker is fully running
sleep 10

# Pull and run Strapi Docker image
docker pull gousiyakhan/my-strapi-app:latest
docker run -d --restart always --name strapi -p 1337:1337 gousiyakhan/my-strapi-app:latest

