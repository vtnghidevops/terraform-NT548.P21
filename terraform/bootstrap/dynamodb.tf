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
  
  # Prevent table deletion if it exists
  lifecycle {
    prevent_destroy = true
  }
} 