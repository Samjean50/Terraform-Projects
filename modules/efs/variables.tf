
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EFS mount targets"
  type        = string
}

variable "ec2_security_group_ids" {
  description = "List of security group IDs allowed to access EFS"
  type        = list(string)
}
