output "strapi_url" {
  description = "Public URL for Strapi (ALB)"
  value       = aws_lb.strapi_alb.dns_name
}

