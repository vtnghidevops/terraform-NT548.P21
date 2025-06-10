# Create KMS key for encryption of S3 bucket and DynamoDB table
# This addresses CKV_AWS_119 and CKV_AWS_145 requirements
resource "aws_kms_key" "terraform_key" {
  count                   = local.create_kms_key ? 1 : 0
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true # Security best practice to rotate keys periodically
  
  tags = {
    Name        = "Terraform KMS Key"
    Environment = "dev"
  }
}

# Create alias for the KMS key for easier reference
resource "aws_kms_alias" "terraform_key" {
  count         = local.create_kms_key ? 1 : 0
  name          = "alias/terraform-key-lab2-group8"
  target_key_id = aws_kms_key.terraform_key[0].key_id
} 