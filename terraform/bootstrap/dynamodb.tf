resource "aws_kms_key" "dynamodb_key" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks-lab2-group8"
  billing_mode   = "PAY_PER_REQUEST"  # Pay only for what you use
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"  # String type attribute
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
  
  # Enable server-side encryption with KMS Customer Managed Key
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_key.arn
  }
  
  # Prevent table deletion if it exists
  lifecycle {
    prevent_destroy = true
  }
} 