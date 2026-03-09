
output "vpc_id" {
  value = aws_vpc.this.id
}


output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}