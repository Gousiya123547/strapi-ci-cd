terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-2"
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-gk"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all subnets in default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick only 1 subnet per AZ for ALB
locals {
  alb_subnets = slice(distinct(data.aws_subnets.default.ids), 0, 3)
}

# Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-ecs"
  description = "Allow HTTP and Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

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
    Name = "strapi-sg-ecs"
  }
}

# Load Balancer
resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb-gk"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi_sg.id]
  subnets            = local.alb_subnets
}

resource "aws_lb_target_group" "strapi_tg" {
  name     = "strapi-tg-gk"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "ip" # Important for FARGATE

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-task"
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::607700977843:role/ecs-task-execution-role"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "607700977843.dkr.ecr.us-east-2.amazonaws.com/strapi-app:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi_logs.name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "strapi"
        }
      }
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "DATABASE_CLIENT", value = "sqlite" },
        { name = "DATABASE_FILENAME", value = "/app/data.db" },
        { name = "APP_KEYS", value = "key1,key2,key3,key4" },
        { name = "JWT_SECRET", value = "jwtSecretKey" },
        { name = "ADMIN_JWT_SECRET", value = "adminJwtSecretKey" },
        { name = "API_TOKEN_SALT", value = "randomSaltValue" }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-gk"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [
    aws_lb_listener.strapi_listener
  ]
}

