# Outputs exported from the developer IAM module.

output "backend_group_name" {
  description = "Name of the backend developer IAM group"
  value       = aws_iam_group.backend_developers.name
}

output "frontend_group_name" {
  description = "Name of the frontend developer IAM group"
  value       = aws_iam_group.frontend_developers.name
}

output "backend_user_arns" {
  description = "Map of username → IAM user ARN for backend developers"
  value       = { for k, u in aws_iam_user.backend_developer : k => u.arn }
}

output "frontend_user_arns" {
  description = "Map of username → IAM user ARN for frontend developers"
  value       = { for k, u in aws_iam_user.frontend_developer : k => u.arn }
}

output "ai_group_name" {
  description = "Name of the AI developer IAM group"
  value       = aws_iam_group.ai_developers.name
}

output "ai_user_arns" {
  description = "Map of username → IAM user ARN for AI developers"
  value       = { for k, u in aws_iam_user.ai_developer : k => u.arn }
}

output "ssm_policy_arn" {
  description = "ARN of the shared SSM port-forwarding policy attached to both groups"
  value       = aws_iam_policy.developer_ssm.arn
}
