variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "digitalboost"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "Availability Zones for subnets"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "name_prefix" {
  description = "Prefix to use for all resources"
  type        = string
  default     = "digitalboost"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "WordPress database name"
  type        = string
  default     = "wordpressdb"
}

variable "db_username" {
  description = "WordPress DB username"
  type        = string
  default     = "wpdbadmin"
}

variable "db_password" {
  description = "WordPress DB password"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID for WordPress EC2 instances"
  type        = string
  default     = "ami-08eb150f611ca277f"
}