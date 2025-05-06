output "vpc_id" {
  description = "ID of the VPC "
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet "
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

output "default_security_group_id" {
  description = "ID of the default security group "
  value       = module.security.default_security_group_id
}

output "public_ec2_security_group_id" {
  description = "ID of the public EC2 security group"
  value       = module.security.public_ec2_security_group_id
}

output "private_ec2_security_group_id" {
  description = "ID of the private EC2 security group "
  value       = module.security.private_ec2_security_group_id
}

output "public_instance_id" {
  description = "ID of the public EC2 instance "
  value       = module.ec2.public_instance_id
}

output "private_instance_id" {
  description = "ID of the private EC2 instance "
  value       = module.ec2.private_instance_id
}

output "public_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = module.ec2.public_instance_public_ip
} 
