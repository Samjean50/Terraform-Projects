variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID for NAT Gateway"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}