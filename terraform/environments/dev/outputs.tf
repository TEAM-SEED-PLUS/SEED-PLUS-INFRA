# Outputs exposed from the dev environment.

# -----------------------------------------------------------------------------
# EC2 connection info
# -----------------------------------------------------------------------------
output "web_public_ip" {
  description = "Elastic IP of the web tier (fixed, use this for domain A-record)"
  value       = aws_eip.web.public_ip
}

output "app_private_ip" {
  description = "Private IP of the app tier EC2 instance"
  value       = module.ec2_app.private_ip
}

output "nat_public_ip" {
  description = "Elastic IP of the NAT instance (bastion / default gateway for private subnets)"
  value       = module.nat_instance.public_ip
}

output "db_private_ip" {
  description = "Private IP of the DB tier EC2 instance"
  value       = module.ec2_db.private_ip
}

output "db_public_ip" {
  description = "Public IP of the DB tier EC2 instance (direct developer access)"
  value       = module.ec2_db.public_ip
}

output "db_instance_id" {
  description = "Instance ID of the DB tier EC2 (for console / SSM access)"
  value       = module.ec2_db.instance_id
}

# -----------------------------------------------------------------------------
# EBS
# -----------------------------------------------------------------------------
output "db_ebs_volume_id" {
  description = "EBS data volume ID attached to the DB instance"
  value       = module.ebs.volume_id
}

# -----------------------------------------------------------------------------
# S3 buckets
# -----------------------------------------------------------------------------
output "s3_app_bucket" {
  description = "Name of the main application S3 bucket"
  value       = module.s3_app.bucket_id
}

output "s3_backup_bucket" {
  description = "Name of the EBS backup S3 bucket"
  value       = module.s3_backup.bucket_id
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

# -----------------------------------------------------------------------------
# CloudWatch
# -----------------------------------------------------------------------------
output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_name
}
