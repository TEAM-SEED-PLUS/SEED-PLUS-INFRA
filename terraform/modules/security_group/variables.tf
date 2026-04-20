# Input variables for the Security Group module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security groups"
  type        = string
}

variable "my_ip" {
  description = "Operator CIDR (e.g. 1.2.3.4/32) for SSH and direct DB access – do not hardcode"
  type        = string
  sensitive   = true
}
