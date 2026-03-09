provider "aws" {
  region = var.aws_region
}

# ---------------------------
# VPC Module
# ---------------------------
module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

# ---------------------------
# NAT Gateway Module
# ---------------------------
module "nat_gateway" {
  source             = "./modules/nat_gateway"
  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.vpc.public_subnet_ids[0]
  private_subnet_ids = module.vpc.private_subnet_ids
  name_prefix        = var.name_prefix
}

# ---------------------------
# WordPress Security Group (root-level to avoid circular dependency)
# ---------------------------
resource "aws_security_group" "wordpress" {
  name        = "${var.project_name}-wordpress-sg"
  description = "Allow web traffic to WordPress EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-wordpress-sg"
  }
}

# ---------------------------
# RDS Module
# (RDS needs the WordPress SG to permit DB access from the web tier)
# ---------------------------
module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  name_prefix        = var.name_prefix
  instance_class     = var.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  wordpress_sg_id    = aws_security_group.wordpress.id
}

# ---------------------------
# ALB Module
# ---------------------------
module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  security_group_id = aws_security_group.wordpress.id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}

# ---------------------------
# EFS Module
# ---------------------------
module "efs" {
  source                 = "./modules/efs"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = aws_security_group.wordpress.id
  ec2_security_group_ids = [aws_security_group.wordpress.id]
}

# ---------------------------
# ASG Module
# ---------------------------
module "asg" {
  source       = "./modules/asg"
  project_name = var.project_name
  ami_id       = var.ami_id

  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  alb_target_group_arn = module.alb.target_group_arn # or module.alb.alb_target_group_arn depending on your alb output
  public_subnet_ids    = module.vpc.public_subnet_ids


  efs_dns_name = module.efs.efs_dns_name
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
  db_endpoint  = module.rds.db_endpoint

  wordpress_sg_id = aws_security_group.wordpress.id
}