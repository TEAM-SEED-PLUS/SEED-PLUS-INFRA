# Input variables for the EC2 module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "tier" {
  description = "Instance tier label used in Name tag (web, app, db)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID – must be passed from a data.aws_ami lookup, never hardcoded"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile to attach"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID in which to launch the instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IP address to the instance"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Shell script executed at instance launch (optional)"
  type        = string
  default     = null
}
