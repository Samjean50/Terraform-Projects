resource "aws_efs_file_system" "this" {
  creation_token   = "wordpress-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "wordpress-efs"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "wordpress-efs-sg"
  description = "SG for EFS to allow NFS from EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port                = 2049
    to_port                  = 2049
    protocol                 = "tcp"
    security_groups          = var.ec2_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-efs-sg"
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}