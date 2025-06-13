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

# Default Security Group attachment via ENI
resource "aws_network_interface" "default_sg_eni" {
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.default.id]
  
  tags = {
    Name = "${var.prefix}-default-sg-eni"
  }
}

# Public EC2 Security Group
resource "aws_security_group" "public_ec2" {
  name        = "${var.prefix}-public-ec2-sg"
  description = "Security group for public EC2 instances"
  vpc_id      = var.vpc_id

  # SSH access from allowed IP - restricted to specific CIDR, never 0.0.0.0/0
  dynamic "ingress" {
    for_each = var.allowed_ip != "0.0.0.0/0" ? [var.allowed_ip] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Allow SSH access from ${ingress.value} (restricted IP)"
    }
  }

  # If no valid IP is provided, create a dummy rule with a very restricted CIDR
  dynamic "ingress" {
    for_each = var.allowed_ip == "0.0.0.0/0" ? ["192.168.1.1/32"] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Allow SSH access from single trusted IP (failsafe)"
    }
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

# Public Security Group attachment via ENI
resource "aws_network_interface" "public_sg_eni" {
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.public_ec2.id]
  
  tags = {
    Name = "${var.prefix}-public-sg-eni"
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

# Private Security Group attachment via ENI
resource "aws_network_interface" "private_sg_eni" {
  subnet_id       = var.private_subnet_id
  security_groups = [aws_security_group.private_ec2.id]
  
  tags = {
    Name = "${var.prefix}-private-sg-eni"
  }
} 