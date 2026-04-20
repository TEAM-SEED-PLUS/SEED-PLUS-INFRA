# Input variables for the IAM module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region used to scope SSM parameter ARNs"
  type        = string
  default     = "ap-northeast-2"
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket used for backups (scoped in policy ARN)"
  type        = string
}
