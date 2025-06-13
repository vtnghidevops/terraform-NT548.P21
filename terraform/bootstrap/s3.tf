# Create S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
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

