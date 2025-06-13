resource "aws_dynamodb_table" "terraform_locks" {
  count          = local.create_table ? 1 : 0
  name           = "terraform-locks-lab2-group8"
  billing_mode   = "PAY_PER_REQUEST"  # Pay only for what you use
  hash_key       = "LockID"
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = local.kms_key_exists ? data.aws_kms_alias.terraform_key.target_key_id : aws_kms_key.terraform_key[0].arn
  }
  
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