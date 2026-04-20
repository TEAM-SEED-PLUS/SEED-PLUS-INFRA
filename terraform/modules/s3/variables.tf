# Input variables for the S3 module.

variable "project" {
  description = "Project name used in tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket (recommended for state and backup buckets)"
  type        = bool
  default     = false
}

variable "enable_lifecycle" {
  description = "Enable lifecycle rules: STANDARD_IA at 30d, GLACIER at 90d, expiry at lifecycle_expiration_days"
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "Days after which objects expire – only used when enable_lifecycle is true"
  type        = number
  default     = 365
}
