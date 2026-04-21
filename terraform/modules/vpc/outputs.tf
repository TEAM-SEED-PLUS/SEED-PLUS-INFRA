# Outputs exported from the VPC module.

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = aws_subnet.web.id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = aws_subnet.app.id
}

output "db_subnet_id" {
  description = "ID of the db subnet"
  value       = aws_subnet.db.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table (app and db subnets – no internet egress)"
  value       = aws_route_table.private.id
}

output "app_subnet_cidr" {
  description = "CIDR block of the app (private) subnet"
  value       = aws_subnet.app.cidr_block
}

output "db_subnet_cidr" {
  description = "CIDR block of the db (private) subnet"
  value       = aws_subnet.db.cidr_block
}
