# Input variables for the developer IAM module.

variable "project" {
  description = "Project name used as a prefix in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region used to construct SSM document ARNs"
  type        = string
  default     = "ap-northeast-2"
}

variable "nat_instance_id" {
  description = "EC2 instance ID of the NAT instance – SSM StartSession is restricted to this target only"
  type        = string
}

variable "developer_usernames" {
  description = "List of IAM usernames to create and add to the developer group"
  type        = list(string)
}
