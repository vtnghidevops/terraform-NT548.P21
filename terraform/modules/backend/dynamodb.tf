resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks-lab2-group8"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  # Enable point-in-time recovery for backups
  point_in_time_recovery {
    enabled = true
  }
  
  # Enable server-side encryption with AWS managed key
  server_side_encryption {
    enabled = true
  }
  
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
}
