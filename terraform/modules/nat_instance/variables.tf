# Input variables for the NAT Instance module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to place the NAT instance"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where the NAT instance will be launched"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs allowed to use this NAT instance for outbound traffic"
  type        = list(string)
}

variable "my_ip" {
  description = "Operator CIDR (e.g. 1.2.3.4/32) for SSH admin access"
  type        = string
  sensitive   = true
}
