# Entry point for the dev environment.
# Instantiates modules defined under terraform/modules/.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  project = "seed-plus"
}

# -----------------------------------------------------------------------------
# Data Source – latest Ubuntu 24.04 LTS AMI (Canonical official account)
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# 1. S3 – Main application bucket
# -----------------------------------------------------------------------------
module "s3_app" {
  source = "../../modules/s3"

  project     = local.project
  environment = var.environment
  bucket_name = "seed-plus-${var.environment}-s3"
}

# -----------------------------------------------------------------------------
# 2. S3 – EBS snapshot backup bucket (versioning + lifecycle)
# -----------------------------------------------------------------------------
module "s3_backup" {
  source = "../../modules/s3"

  project     = local.project
  environment = var.environment
  bucket_name = "seed-plus-${var.environment}-ebs-backup"

  versioning_enabled        = true
  enable_lifecycle          = true
  lifecycle_expiration_days = 365
}

# -----------------------------------------------------------------------------
# 3. IAM – EC2 instance profile (references s3_backup for scoped S3 policy)
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project     = local.project
  environment        = var.environment
  aws_region         = var.aws_region
  backup_bucket_name = module.s3_backup.bucket_id
}

# -----------------------------------------------------------------------------
# 4. VPC – subnets, IGW, route table (single AZ PoC)
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  project     = local.project
  environment       = var.environment
  availability_zone = var.availability_zone
}

# -----------------------------------------------------------------------------
# 5. Security Groups – web / app / db tiers
# -----------------------------------------------------------------------------
module "security_group" {
  source = "../../modules/security_group"

  project     = local.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  my_ip       = var.my_ip
  db_port     = var.db_port
}

# -----------------------------------------------------------------------------
# 6. EC2 – Web Tier
# -----------------------------------------------------------------------------
module "ec2_web" {
  source = "../../modules/ec2"

  project     = local.project
  environment           = var.environment
  tier                  = "web"
  ami_id                = data.aws_ami.ubuntu.id
  key_name              = var.key_name
  instance_profile_name = module.iam.ec2_instance_profile_name
  subnet_id             = module.vpc.web_subnet_id
  security_group_id     = module.security_group.sg_web_id

  associate_public_ip_address = true
}

# -----------------------------------------------------------------------------
# 7. EC2 – App Tier
# -----------------------------------------------------------------------------
module "ec2_app" {
  source = "../../modules/ec2"

  project     = local.project
  environment           = var.environment
  tier                  = "app"
  ami_id                = data.aws_ami.ubuntu.id
  key_name              = var.key_name
  instance_profile_name = module.iam.ec2_instance_profile_name
  subnet_id             = module.vpc.app_subnet_id
  security_group_id     = module.security_group.sg_app_id

  associate_public_ip_address = false
}

# -----------------------------------------------------------------------------
# 8. EC2 – DB Tier
# -----------------------------------------------------------------------------
module "ec2_db" {
  source = "../../modules/ec2"

  project               = local.project
  environment           = var.environment
  tier                  = "db"
  ami_id                = data.aws_ami.ubuntu.id
  key_name              = var.key_name
  instance_profile_name = module.iam.ec2_instance_profile_name
  subnet_id             = module.vpc.db_subnet_id
  security_group_id     = module.security_group.sg_db_id

  associate_public_ip_address = false
}

# -----------------------------------------------------------------------------
# 9. NAT Instance – t4g.nano ARM64, SSM-only access, routes private subnet traffic
# -----------------------------------------------------------------------------
module "nat_instance" {
  source = "../../modules/nat_instance"

  project              = local.project
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.web_subnet_id
  private_subnet_cidrs = [module.vpc.app_subnet_cidr, module.vpc.db_subnet_cidr]
  my_ip                = var.my_ip
}

# Default route in the private route table → NAT instance ENI
resource "aws_route" "private_nat" {
  route_table_id         = module.vpc.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.primary_network_interface_id
}

# -----------------------------------------------------------------------------
# 10. EBS – DB data volume (50 GB gp3, Backup tag for DLM)
# -----------------------------------------------------------------------------
module "ebs" {
  source = "../../modules/ebs"

  project     = local.project
  environment       = var.environment
  availability_zone = var.availability_zone
  instance_id       = module.ec2_db.instance_id
}
