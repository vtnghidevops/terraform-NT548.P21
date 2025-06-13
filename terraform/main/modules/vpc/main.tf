# Get AWS account ID
data "aws_caller_identity" "current" {}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-policy-cloudwatch",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch to use the key",
        Effect = "Allow",
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name = "${var.prefix}-cloudwatch-kms-key"
  }
}

# VPC Flow Log
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

# VPC Flow Log CloudWatch Log Group
resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = "/aws/vpc-flow-log/${var.prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch.arn
  
  tags = {
    Name = "${var.prefix}-vpc-flow-log-group"
  }
}

# VPC Flow Log IAM Role
resource "aws_iam_role" "flow_log_role" {
  name = "${var.prefix}-flow-log-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# VPC Flow Log IAM Policy
resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.prefix}-flow-log-policy"
  role = aws_iam_role.flow_log_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.flow_log_group.arn}:*"
      },
      {
        Action = [
          "logs:DescribeLogGroups"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.flow_log_group.arn}"
      }
    ]
  })
}

# Default Security Group Management
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  
  # Explicitly deny all inbound traffic
  # No ingress rules means all inbound traffic is denied

  # Explicitly deny all outbound traffic
  # No egress rules means all outbound traffic is denied
  
  tags = {
    Name = "${var.prefix}-default-sg-managed"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  
  tags = {
    Name = "${var.prefix}-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}b"
  
  tags = {
    Name = "${var.prefix}-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  
  tags = {
    Name = "${var.prefix}-nat-gateway"
  }
  
  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "${var.prefix}-private-route-table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
} 