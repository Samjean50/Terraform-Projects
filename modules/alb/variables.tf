variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "security_group_id" {
  description = "Security group for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}