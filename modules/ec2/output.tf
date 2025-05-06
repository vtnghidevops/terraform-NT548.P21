output "public_instance_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public.id
}

output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

output "public_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public.public_ip
} 
