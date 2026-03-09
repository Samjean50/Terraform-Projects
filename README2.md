# Automated WordPress Deployment on AWS

A Terraform-based infrastructure project that provisions a production-grade, highly available WordPress environment on AWS for DigitalBoost, a digital marketing agency. The entire stack is automated, repeatable, and managed as Infrastructure-as-Code.

---

## Architecture Overview

```
Internet
   │
   ▼
Application Load Balancer (Public)
   │
   ▼
Auto Scaling Group ── EC2 Instances (Private Subnets)
   │                        │
   │                    EFS Mount
   │                  (Shared WP files)
   │
   ▼
RDS MySQL (Private Subnet)
```

**Key design decisions:**
- EC2 instances live in **private subnets** — never directly exposed to the internet
- **NAT Gateway** in the public subnet allows EC2s to pull updates and packages outbound
- **EFS** is mounted across all EC2 instances so WordPress files are consistent regardless of which instance serves the request
- **RDS** is only reachable from the EC2 security group, not from the internet
- **ALB** is the single public entry point, distributing traffic across the Auto Scaling Group

---

## Infrastructure Components

| Component | Details |
|-----------|---------|
| VPC | Custom VPC (`10.0.0.0/16`) with public and private subnets across 2 AZs |
| Internet Gateway | Attached to VPC for public subnet internet access |
| NAT Gateway | Deployed in public subnet; enables outbound internet from private subnets |
| Route Tables | Separate route tables for public and private subnets |
| RDS (MySQL) | Managed MySQL instance in private subnet; accessible only from EC2 SG |
| EFS | Shared file system mounted on all EC2 instances for WordPress files |
| EC2 | WordPress installed via User Data script; part of Auto Scaling Group |
| ALB | Public-facing load balancer routing HTTPS traffic to EC2 instances |
| Auto Scaling Group | Scales EC2s in/out based on CPU utilisation; uses Launch Template |
| Security Groups | Least-privilege rules for ALB, EC2, RDS, and EFS |
| IAM Roles | EC2 instance profile for EFS access and metadata retrieval |

---

## Security Design

- EC2 instances are in **private subnets** with no direct public IP
- SSH access to EC2 is restricted to your IP address only
- RDS port 3306 is open **only** to the EC2 security group
- EFS mount targets are restricted to EC2 security group
- RDS storage is **encrypted at rest**
- EFS is **encrypted at rest**
- No sensitive values are hardcoded — all credentials passed via `terraform.tfvars`
- IAM roles used instead of static access keys on EC2

---

## Prerequisites

- Terraform v1.5 or higher
- AWS CLI installed and configured (`aws configure`)
- An AWS IAM user with permissions for VPC, EC2, RDS, EFS, IAM, and ELB
- Git

---

## Project Structure

```
Terraform-Projects/
├── main.tf                  # Core infrastructure resources
├── variables.tf             # Input variable declarations
├── terraform.tfvars         # Variable values (do not commit secrets)
├── outputs.tf               # Output values (ALB DNS, RDS endpoint, etc.)
├── user_data.sh             # EC2 bootstrap script (WordPress install + EFS mount)
├── modules/                 # Reusable Terraform modules
│   ├── vpc/
│   ├── rds/
│   ├── efs/
│   ├── ec2/
│   └── alb/
└── images/                  # Architecture diagrams
```

---

## Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/Samjean50/Terraform-Projects.git
cd Terraform-Projects
```

### Step 2: Configure Variables

Edit `terraform.tfvars` with your values:

```hcl
region               = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
db_username          = "admin"
db_password          = "your_secure_password"
my_ip                = "your.ip.address.here/32"
```

> **Note:** Never commit `terraform.tfvars` to a public repository if it contains passwords. Add it to `.gitignore` or use AWS Secrets Manager for production deployments.

### Step 3: Initialise Terraform

```bash
terraform init
```

### Step 4: Review the Plan

```bash
terraform plan -out=tfplan
```

Review the output carefully before applying — confirm resource counts match expectations.

### Step 5: Apply Infrastructure

```bash
terraform apply tfplan
```

Provisioning typically takes 10–15 minutes, primarily due to RDS instance creation.

### Step 6: Access WordPress

```bash
# Get the ALB DNS name from outputs
terraform output alb_dns_name
```

Open the ALB DNS name in your browser and complete the WordPress setup wizard using the RDS credentials from your `terraform.tfvars`.

---

## Testing Auto Scaling

Once the site is live, simulate traffic to observe Auto Scaling in action:

```bash
# Using Apache Bench
ab -n 10000 -c 100 http://<ALB_DNS_NAME>/

# Or using k6
k6 run --vus 50 --duration 60s script.js
```

Watch new EC2 instances launch in the AWS Console under **EC2 → Auto Scaling Groups** as CPU utilisation rises above the scale-out threshold.

---

## Outputs

After `terraform apply` completes, the following values are available:

```bash
terraform output
```

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Public URL to access the WordPress site |
| `rds_endpoint` | MySQL endpoint for WordPress configuration |
| `efs_id` | EFS File System ID |
| `vpc_id` | VPC ID for reference |

---

## Documentation Checklist

| Component | Implemented |
|-----------|-------------|
| VPC + Subnets | ✅ |
| Internet Gateway + Route Tables | ✅ |
| NAT Gateway | ✅ |
| RDS MySQL (Private) | ✅ |
| EFS (Shared Storage) | ✅ |
| EC2 with User Data | ✅ |
| Application Load Balancer | ✅ |
| Auto Scaling Group | ✅ |
| Security Groups | ✅ |
| IAM Roles | ✅ |

---

## Teardown

To destroy all provisioned resources:

```bash
terraform destroy
```

Type `yes` when prompted. This removes all AWS resources created by this project, including VPC, EC2, RDS, EFS, ALB, and NAT Gateway.

> **Important:** Destroying the RDS instance deletes all data. Ensure you have a snapshot or backup before running `terraform destroy` in a real environment.

---

## Author

**Samson Bakare**  
DevOps Engineer | AWS | Terraform | Kubernetes  
[GitHub: Samjean50](https://github.com/Samjean50)
