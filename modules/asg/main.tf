resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = var.ami_id
  instance_type = "t3.micro"
user_data = base64encode(templatefile("${path.module}/userdata.sh", {
  efs_dns_name = var.efs_dns_name
  db_endpoint  = var.db_endpoint
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
}))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.wordpress_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-wordpress"
    }
  }
}

resource "aws_autoscaling_group" "wordpress" {
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = var.public_subnet_ids
  target_group_arns         = [var.alb_target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-wordpress"
    propagate_at_launch = true
  }
}
