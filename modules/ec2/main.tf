# Public EC2 Instance
resource "aws_instance" "public" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.prefix}-public-ec2"
  }
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.prefix}-private-ec2"
  }
} 
