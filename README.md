# Automated WordPress Deployment on AWS (Terraform Capstone Project)

## Project Overview
DigitalBoost, a digital marketing agency, aims to enhance its online presence by launching a high-performance, scalable, and secure WordPress website. As an AWS Solutions Architect, your responsibility is to design and implement this infrastructure using Terraform to ensure full automation, repeatability, and infrastructure-as-code principles.

This project includes provisioning:

* Custom VPC with public/private subnets
* NAT Gateway for secure internet access
* MySQL RDS for backend database
* EFS for shared WordPress files
* EC2 instances running WordPress
* Load Balancer with Auto Scaling
* Properly configured IAM and security groups



## Infrastructure Components
1. VPC Setup
Creates a Virtual Private Cloud with CIDR range
Public and Private subnets across 2 AZs
Internet Gateway and Route Tables
2. NAT Gateway
Public subnet NAT Gateway
Allows internet access from private subnets
3. MySQL RDS (Private Subnet)
Managed MySQL instance
Secured via security group (only EC2 can access)
4. EFS (Elastic File System)
Shared storage for WordPress files
Mounted across AZs via EC2
5. EC2 Instance(s)
WordPress installed via User Data script
Auto Scaling Enabled
6. ALB (Application Load Balancer)
Public ALB routing to EC2 instances
Integrated with Auto Scaling Group
7. Auto Scaling Group
Dynamically adds/removes EC2s based on CPU usage
Launch Template includes EFS mounting and WP install

## Security Considerations
- EC2 only accessible via SSH from your IP
- RDS only accessible from EC2 security group
- IAM roles used for accessing EFS and EC2 metadata
- Encrypted RDS and EFS
- Use Terraform variables.tf to avoid hardcoding sensitive values

## Requirements
- Terraform v1.5+
- AWS CLI configured (aws configure)
- Git (for version control)
- An AWS IAM user with appropriate permissions

![terraform](images/1.png)
![terraform](images/2.png)
![terraform](images/3.png)
![terraform](images/4.png)
![terraform](images/5.png)
![terraform](images/6.png)
![terraform](images/7.png)
![terraform](images/8.png)
![terraform](images/9.png)
![terraform](images/10.png)
![terraform](images/11.png)
![terraform](images/12.png)
![terraform](images/13.png)
![terraform](images/14.png)
![terraform](images/15.png)
![terraform](images/16.png)
![terraform](images/17.png)
![terraform](images/18.png)
![terraform](images/19.png)
![terraform](images/10.png)
![terraform](images/21.png)
![terraform](images/22.png)
![terraform](images/23.png)
![terraform](images/24.png)
![terraform](images/25.png)
![terraform](images/26.png)
![terraform](images/wp1.png)
![terraform](images/wp2.png)
![terraform](images/wp3.png)
![terraform](images/wp4.png)
![terraform](images/wp5.png)
![terraform](images/wp6.png)
![terraform](images/wp7.png)
![terraform](images/wp8.png)
![terraform](images/wp9.png)
![terraform](images/wp10.png)
![terraform](images/wp11.png)
![terraform](images/wp12.png)
![terraform](images/wp13.png)
![terraform](images/wp14.png)
![terraform](images/wp15.png)
![terraform](images/wp16.png)
![terraform](images/wp17.png)

## Deployment Instructions
### Step 1: Clone the Repository
git clone https://github.com/yourusername/automated-wordpress-aws.git
cd automated-wordpress-aws


### Step 2: Configure Variables

Edit terraform.tfvars:

region        = "us-east-1"
vpc_cidr      = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
db_username   = "admin"
db_password   = "your_secure_password"

### Step 3: Initialize Terraform
terraform init

### Step 4: Plan Infrastructure
terraform plan -out=tfplan

### Step 5: Apply Infrastructure
terraform apply tfplan

### Step 6: Access WordPress Site

Find the ALB DNS name in terraform output

Open it in your browser

Complete WordPress setup wizard using the provided RDS credentials

## Demonstration Guidelines

- Access the WordPress website via ALB DNS

- Simulate traffic with tools like ab or k6

- Observe new EC2 instances launching with Auto Scaling

## Documentation Checklist
VPC	✅ Yes
NAT Gateway	✅ Yes
RDS	✅ Yes
EFS	✅ Yes
EC2	✅ Yes
ALB	✅ Yes
ASG	✅ Yes
Security	✅ Yes
Cleanup (Tear Down Infrastructure)
terraform destroy
