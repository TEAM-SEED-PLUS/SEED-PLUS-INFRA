# Remote backend configuration for the dev environment.
# Stores Terraform state in S3 with DynamoDB locking.

terraform {
  backend "s3" {
    bucket         = "seed-plus-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "seed-plus-state-lock"
    encrypt        = true
  }
}
