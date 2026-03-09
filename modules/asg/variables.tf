variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ARN of the target group from the ALB"
  type        = string
}

variable "efs_dns_name" {
  description = "DNS name of the EFS to mount"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "db_name" {
  description = "Database name for WordPress"
  type        = string
}

variable "db_username" {
  description = "Database username for WordPress"
  type        = string
}

variable "db_password" {
  description = "Database password for WordPress"
  type        = string
  sensitive   = true
}

variable "db_endpoint" {
  description = "RDS endpoint for WordPress"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for WordPress EC2 instances"
  type        = string
}

variable "wordpress_sg_id" {
  description = "Security Group ID for WordPress instances"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB or EC2 instances"
  type        = list(string)
}