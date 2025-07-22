#!/bin/bash
# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
service docker start
usermod -aG docker ec2-user

# Pull and run Strapi container
docker run -d -p 1337:1337 gousiyakhan/strapi-app:${image_tag}

