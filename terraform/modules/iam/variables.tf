# Input variables for the IAM module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "name_suffix" {
  description = "Short label appended to IAM resource names to avoid conflicts when the module is instantiated more than once (e.g. 'web', 'private')"
  type        = string
  default     = "ec2"
}

variable "enable_ssm" {
  description = "Attach AmazonSSMManagedInstanceCore to the role – set false for tiers that must not be SSM-managed"
  type        = bool
  default     = true
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
  description = "Name of the S3 bucket used for backups (scoped in policy ARN). Leave empty to skip S3 backup policy."
  type        = string
  default     = ""
}
