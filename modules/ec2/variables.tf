variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "terraform-lab1"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-0e83be366243f524a"  # Amazon Linux 2023 in us-east-1
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "public_security_group_id" {
  description = "ID of the public security group"
  type        = string
}

variable "private_security_group_id" {
  description = "ID of the private security group"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = null
} 
