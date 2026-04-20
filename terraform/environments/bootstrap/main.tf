# Bootstrap environment – provisions the Terraform state bucket and DynamoDB lock table.
# Uses a local backend intentionally: these resources must exist before the S3 backend
# in other environments can be initialized.
#
# Run order:
#   1. terraform init && terraform apply   (this directory only, once per project)
#   2. Verify seed-plus-tfstate bucket and seed-plus-state-lock table exist
#   3. Run terraform init in environments/dev to activate the S3 backend

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Terraform State Bucket
# -----------------------------------------------------------------------------
module "s3_tfstate" {
  source = "../../modules/s3"

  project     = "seed-plus"
  environment = var.environment
  bucket_name = var.tfstate_bucket_name

  versioning_enabled = true # Required for state history and recovery
}

# -----------------------------------------------------------------------------
# DynamoDB State Lock Table
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "state_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = var.environment
    Project     = "seed-plus"
  }
}
