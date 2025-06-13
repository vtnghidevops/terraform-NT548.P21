locals {
  safe_allowed_ip = var.allowed_ip == "0.0.0.0/0" ? "192.168.1.1/32" : var.allowed_ip
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  prefix              = var.prefix
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Security Module
module "security" {
  source = "./modules/security"

  prefix            = var.prefix
  vpc_id            = module.vpc.vpc_id
  allowed_ip        = local.safe_allowed_ip
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  prefix                    = var.prefix
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  public_subnet_id          = module.vpc.public_subnet_id
  private_subnet_id         = module.vpc.private_subnet_id
  public_security_group_id  = module.security.public_ec2_security_group_id
  private_security_group_id = module.security.private_ec2_security_group_id
  key_name                  = var.key_name
}

resource "aws_network_interface" "default_eni" {
  subnet_id       = module.vpc.public_subnet_id
  security_groups = [module.security.default_security_group_id]

  tags = {
    Name = "${var.prefix}-default-eni"
  }
} 