# Default VPC Security Group
resource "aws_security_group" "default" {
  name        = "${var.prefix}-default-sg"
  description = "Default security group for VPC"
  vpc_id      = var.vpc_id

  # Restrict outbound traffic to specific ports and protocols
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-default-sg"
  }
}

# Public EC2 Security Group
resource "aws_security_group" "public_ec2" {
  name        = "${var.prefix}-public-ec2-sg"
  description = "Security group for public EC2 instances"
  vpc_id      = var.vpc_id

  # SSH access from allowed IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "Allow SSH access from specified IP"
  }

  # Restrict outbound traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-public-ec2-sg"
  }
}

# Private EC2 Security Group
resource "aws_security_group" "private_ec2" {
  name        = "${var.prefix}-private-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = var.vpc_id

  # SSH access from public EC2 instances
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
    description     = "Allow SSH access from public EC2 instances"
  }

  # Restrict outbound traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-private-ec2-sg"
  }
} 