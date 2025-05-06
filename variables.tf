variable "prefix" {
  description = "Prefix for all resources "
  type        = string
  default     = "terraform-demo"
}

variable "region" {
  description = "AWS region "
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "allowed_ip" {
  description = "IP address allowed to connect to public instances (địa chỉ IP được phép)"
  type        = string
  default     = "0.0.0.0/0"  # In production, this should be restricted
}

variable "ami_id" {
  description = "AMI ID for the instances (ID của Amazon Machine Image)"
  type        = string
  default     = "ami-0e83be366243f524a"  # Amazon Linux 2023 in us-east-1
}

variable "instance_type" {
  description = "Instance type for the EC2 instances (loại máy chủ)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access (tên cặp khóa)"
  type        = string
  default     = null
}
