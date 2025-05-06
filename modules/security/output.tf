output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}

output "public_ec2_security_group_id" {
  description = "ID of the public EC2 security group"
  value       = aws_security_group.public_ec2.id
}

output "private_ec2_security_group_id" {
  description = "ID of the private EC2 security group"
  value       = aws_security_group.private_ec2.id
} 
