provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  prefix             = var.prefix
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}


module "security" {
  source = "./modules/security"

  prefix     = var.prefix
  vpc_id     = module.vpc.vpc_id
  allowed_ip = var.allowed_ip
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  prefix                  = var.prefix
  ami_id                  = var.ami_id
  instance_type           = var.instance_type
  public_subnet_id        = module.vpc.public_subnet_id
  private_subnet_id       = module.vpc.private_subnet_id
  public_security_group_id  = module.security.public_ec2_security_group_id
  private_security_group_id = module.security.private_ec2_security_group_id
  key_name                = var.key_name
} 
