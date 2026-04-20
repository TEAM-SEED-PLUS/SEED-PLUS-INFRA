# Outputs exported from the Security Group module.

output "sg_web_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "sg_app_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}

output "sg_db_id" {
  description = "ID of the DB security group"
  value       = aws_security_group.db.id
}
