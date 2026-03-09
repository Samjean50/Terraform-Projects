# output "wordpress_sg_id" {
  #description = "Security Group ID for WordPress instances"
  #value       = aws_security_group.wordpress.id
# }

output "user_data_debug" {
  value = templatefile("${path.module}/userdata.sh", {
    efs_dns_name = var.efs_dns_name
    db_endpoint  = var.db_endpoint
    db_name      = var.db_name
    db_username  = var.db_username
    db_password  = var.db_password
  })
  sensitive = true
}