# Outputs exported from the EBS module.

output "volume_id" {
  description = "ID of the EBS data volume"
  value       = aws_ebs_volume.this.id
}

output "volume_arn" {
  description = "ARN of the EBS data volume"
  value       = aws_ebs_volume.this.arn
}
