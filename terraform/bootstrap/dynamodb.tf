# Check if DynamoDB table exists
data "aws_dynamodb_table" "terraform_locks_exists" {
  count = 1
  name  = "terraform-locks-lab2-group8"
}

locals {
  dynamodb_table_exists = length(data.aws_dynamodb_table.terraform_locks_exists) > 0 ? true : false
}

resource "aws_dynamodb_table" "terraform_locks" {
  count          = local.dynamodb_table_exists ? 0 : 1
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
    ignore_changes  = all
  }
} 