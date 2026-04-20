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
# 1. S3 – Main application bucket (seed-plus-s3)
# -----------------------------------------------------------------------------
module "s3_app" {
  source = "../../modules/s3"

  project     = "seed-plus"
  environment = var.environment
  bucket_name = "seed-plus-s3"
}

# -----------------------------------------------------------------------------
# 2. S3 – EBS snapshot backup bucket (versioning + lifecycle)
# -----------------------------------------------------------------------------
module "s3_backup" {
  source = "../../modules/s3"

  project     = "seed-plus"
  environment = var.environment
  bucket_name = "seed-plus-ebs-backup"

  versioning_enabled        = true
  enable_lifecycle          = true
  lifecycle_expiration_days = 365
}

# -----------------------------------------------------------------------------
# 3. IAM – EC2 instance profile (references s3_backup for scoped S3 policy)
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project            = "seed-plus"
  environment        = var.environment
  aws_region         = var.aws_region
  backup_bucket_name = module.s3_backup.bucket_id
}

# -----------------------------------------------------------------------------
# 4. VPC – subnets, IGW, route table (single AZ PoC)
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  project           = "seed-plus"
  environment       = var.environment
  availability_zone = var.availability_zone
}

# -----------------------------------------------------------------------------
# 5. Security Groups – web / app / db tiers
# -----------------------------------------------------------------------------
module "security_group" {
  source = "../../modules/security_group"

  project     = "seed-plus"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  my_ip       = var.my_ip
}

# -----------------------------------------------------------------------------
# 6. EC2 – Web Tier
# -----------------------------------------------------------------------------
module "ec2_web" {
  source = "../../modules/ec2"

  project               = "seed-plus"
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

  project               = "seed-plus"
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
# 8. EC2 – DB Tier (includes user_data: EBS mount + PostgreSQL setup)
# -----------------------------------------------------------------------------
module "ec2_db" {
  source = "../../modules/ec2"

  project               = "seed-plus"
  environment           = var.environment
  tier                  = "db"
  ami_id                = data.aws_ami.ubuntu.id
  key_name              = var.key_name
  instance_profile_name = module.iam.ec2_instance_profile_name
  subnet_id             = module.vpc.db_subnet_id
  security_group_id     = module.security_group.sg_db_id

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    # Wait for /dev/xvdb – EBS volume may arrive after cloud-init starts
    while [ ! -b /dev/xvdb ]; do sleep 5; done

    # Install PostgreSQL
    apt-get update -y
    apt-get install -y postgresql postgresql-contrib

    # Stop the default cluster before relocating its data directory
    systemctl stop postgresql

    # Format the EBS data volume with xfs
    mkfs.xfs /dev/xvdb

    # Create mount point and mount permanently
    mkdir -p /data/postgresql
    mount /dev/xvdb /data/postgresql
    echo "/dev/xvdb /data/postgresql xfs defaults,nofail 0 2" >> /etc/fstab

    # Detect installed PostgreSQL major version (e.g. 16 on Ubuntu 24.04)
    PG_VER=$(pg_lsclusters -h | awk 'NR==1{print $1}')

    # Migrate cluster data to the new volume
    rsync -a /var/lib/postgresql/$PG_VER/main/ /data/postgresql/

    # Hand ownership to the postgres system user
    chown -R postgres:postgres /data/postgresql

    # Point the cluster configuration at the new data directory
    sed -i "s|^#*data_directory\s*=.*|data_directory = '/data/postgresql'|" \
      /etc/postgresql/$PG_VER/main/postgresql.conf

    systemctl start postgresql
  EOF
}

# -----------------------------------------------------------------------------
# 9. EBS – DB data volume (50 GB gp3, Backup tag for DLM)
# -----------------------------------------------------------------------------
module "ebs" {
  source = "../../modules/ebs"

  project           = "seed-plus"
  environment       = var.environment
  availability_zone = var.availability_zone
  instance_id       = module.ec2_db.instance_id
}
