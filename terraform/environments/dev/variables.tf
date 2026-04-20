# Input variables for the dev environment.

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "availability_zone" {
  description = "Single AZ for all subnets and EBS volumes (PoC – no HA)"
  type        = string
  default     = "ap-northeast-2a"
}

variable "my_ip" {
  description = "Operator CIDR (e.g. 1.2.3.4/32) for SSH and direct DB access"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}
