# Default VPC Security Group
resource "aws_security_group" "default" {
  name        = "${var.prefix}-default-sg"
  description = "Default security group for VPC"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-default-sg"
  }
}
