# Outputs exported from the bootstrap environment.

output "tfstate_bucket_id" {
  description = "Name of the Terraform state S3 bucket"
  value       = module.s3_tfstate.bucket_id
}

output "tfstate_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = module.s3_tfstate.bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB state lock table"
  value       = aws_dynamodb_table.state_lock.name
}
