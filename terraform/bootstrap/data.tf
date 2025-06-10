# Check if S3 bucket already exists
data "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-lab2-group8"
}

# Check if DynamoDB table already exists
data "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-locks-lab2-group8"
}

# Check if KMS key already exists
data "aws_kms_alias" "terraform_key" {
  name = "alias/terraform-key-lab2-group8"
} 