# Check if S3 bucket for Terraform state exists
data "aws_s3_bucket" "terraform_state_exists" {
  count  = 1
  bucket = "terraform-state-bucket-lab2-group8"
}

locals {
  s3_bucket_exists = length(data.aws_s3_bucket.terraform_state_exists) > 0 ? true : false
}

# Create S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = "terraform-state-bucket-lab2-group8"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
  
  # Prevent bucket deletion if it exists
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

