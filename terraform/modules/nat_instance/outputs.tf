# Outputs exported from the NAT Instance module.

output "sg_nat_id" {
  description = "ID of the NAT instance security group – used for cross-module SG rules"
  value       = aws_security_group.nat.id
}

output "instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "primary_network_interface_id" {
  description = "Primary ENI ID of the NAT instance – used as the next-hop in the private route table"
  value       = aws_instance.nat.primary_network_interface_id
}

output "public_ip" {
  description = "Elastic IP address assigned to the NAT instance"
  value       = aws_eip.nat.public_ip
}
