output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.wordpress_alb.dns_name
}

output "target_group_arn" {
  description = "Target Group ARN for ALB"
  value       = aws_lb_target_group.this.arn
}