provider "aws" {
  region = "us-east-1"
}

# Tạo S3 bucket cho Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-lab2-group8"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

# Bật versioning trên S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Chặn public access cho S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tạo DynamoDB table cho state locking
resource "aws_dynamodb_table" "terraform_locks" {
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
} 