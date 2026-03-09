output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "wordpress_url" {
  description = "WordPress Site URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}