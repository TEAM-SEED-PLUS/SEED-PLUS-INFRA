# Input variables for the dev environment.
# ─────────────────────────────────────────────────────────────────────────────
# REQUIRED  – no default; must be set in terraform.tfvars before apply
# OPTIONAL  – sensible default provided; override in terraform.tfvars if needed
# ─────────────────────────────────────────────────────────────────────────────

# =============================================================================
# REQUIRED – fill these in terraform.tfvars
# =============================================================================

variable "my_ip" {
  description = "Operator CIDR for SSH admin access to all EC2 instances and the NAT instance (e.g. '1.2.3.4/32')"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the existing EC2 key pair in ap-northeast-2 used for SSH access"
  type        = string
}

# =============================================================================
# OPTIONAL – defaults are production-ready for this PoC; override if needed
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy all resources into"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Deployment environment label applied to all resource names and tags"
  type        = string
  default     = "dev"
}

variable "availability_zone" {
  description = "Single AZ for all subnets and EBS volumes (PoC – no HA)"
  type        = string
  default     = "ap-northeast-2a"
}

variable "db_port" {
  description = "Non-default PostgreSQL listen port – avoids well-known port 5432 to reduce noise"
  type        = number
  default     = 15921
}
