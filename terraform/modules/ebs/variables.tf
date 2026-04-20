# Input variables for the EBS module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the EBS volume – must match the attached instance"
  type        = string
}

variable "instance_id" {
  description = "Instance ID of the EC2 instance to attach the volume to"
  type        = string
}
