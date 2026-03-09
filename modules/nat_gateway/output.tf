output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "eip_id" {
  description = "Elastic IP ID"
  value       = aws_eip.nat.id
}