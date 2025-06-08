# Public EC2 Instance
resource "aws_instance" "public" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_security_group_id]
  key_name               = var.key_name
  ebs_optimized          = true
  monitoring             = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.prefix}-public-ec2"
  }
}

# Elastic IP for Public EC2
resource "aws_eip" "public_instance" {
  instance = aws_instance.public.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.prefix}-public-ec2-eip"
  }
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_security_group_id]
  key_name               = var.key_name
  ebs_optimized          = true
  monitoring             = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.prefix}-private-ec2"
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.prefix}-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name = "${var.prefix}-ec2-role"
  }
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
} 