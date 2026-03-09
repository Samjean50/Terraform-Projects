output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
}


output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}