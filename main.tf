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
}
