# Input variables for the bootstrap environment.

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment tag applied to bootstrap resources"
  type        = string
  default     = "mgmt"
}

variable "tfstate_bucket_name" {
  description = "Globally unique name for the Terraform state S3 bucket"
  type        = string
  default     = "seed-plus-tfstate"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "seed-plus-state-lock"
}
