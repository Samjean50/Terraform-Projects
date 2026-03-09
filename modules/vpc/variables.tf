variable "project_name" {
  type        = string
  description = "Prefix for resource naming"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}