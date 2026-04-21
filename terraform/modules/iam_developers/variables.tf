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

variable "backend_developer_usernames" {
  description = "IAM usernames for backend developers – added to the backend-developers group (DB + App access via NAT)"
  type        = list(string)
  default     = []
}

variable "frontend_developer_usernames" {
  description = "IAM usernames for frontend developers – added to the frontend-developers group (App + Web access via NAT, no DB)"
  type        = list(string)
  default     = []
}

variable "ai_developer_usernames" {
  description = "IAM usernames for AI developers – added to the ai-developers group (DB access via NAT only)"
  type        = list(string)
  default     = []
}
