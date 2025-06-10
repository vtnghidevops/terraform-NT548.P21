provider "aws" {
  region = "us-east-1"
}

# Check if S3 bucket already exists by catching errors
data "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-lab2-group8"
}

# Check if DynamoDB table already exists by catching errors
data "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-locks-lab2-group8"
}

locals {
  # Determine if bucket exists
  bucket_exists = try(data.aws_s3_bucket.terraform_state.bucket != "", false)
  
  # Determine if table exists
  table_exists = try(data.aws_dynamodb_table.terraform_locks.name != "", false)
  
  # Determine if bucket needs to be created
  create_bucket = !local.bucket_exists
  
  # Determine if DynamoDB table needs to be created
  create_table = !local.table_exists
}

# Create S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = "terraform-state-bucket-lab2-group8"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
  
  # Prevent bucket deletion if it exists
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for state locking if it doesn't exist
resource "aws_dynamodb_table" "terraform_locks" {
  count          = local.create_table ? 1 : 0
  name           = "terraform-locks-lab2-group8"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  # Enable point-in-time recovery for backups
  point_in_time_recovery {
    enabled = true
  }
  
  # Enable server-side encryption
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
  
  # Prevent table deletion if it exists
  lifecycle {
    prevent_destroy = true
  }
}

# Output status message
output "status" {
  value = <<EOT
S3 Bucket Status: ${local.bucket_exists ? "Using existing bucket" : "Created new bucket"}
DynamoDB Table Status: ${local.table_exists ? "Using existing table" : "Created new table"}
EOT
}

# Output bucket name
output "bucket_name" {
  value = local.bucket_exists ? data.aws_s3_bucket.terraform_state.bucket : (local.create_bucket ? aws_s3_bucket.terraform_state[0].bucket : "")
}

# Output table name
output "table_name" {
  value = local.table_exists ? data.aws_dynamodb_table.terraform_locks.name : (local.create_table ? aws_dynamodb_table.terraform_locks[0].name : "")
} 