variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment label (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where metrics are collected"
  type        = string
}

variable "web_instance_id" {
  description = "Instance ID of the Web tier EC2"
  type        = string
}

variable "app_instance_id" {
  description = "Instance ID of the App tier EC2"
  type        = string
}

variable "db_instance_id" {
  description = "Instance ID of the DB tier EC2"
  type        = string
}

variable "nat_instance_id" {
  description = "Instance ID of the NAT EC2"
  type        = string
}

variable "ebs_volume_id" {
  description = "EBS volume ID of the DB data volume"
  type        = string
}
