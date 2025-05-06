variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "terraform-lab1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_ip" {
  description = "IP address allowed to connect to public instances"
  type        = string
  default     = "14.169.33.91/32"  
} 
