locals {
  # Determine if bucket exists by checking if data source returned a value
  bucket_exists = try(data.aws_s3_bucket.terraform_state.bucket != "", false)
  
  # Determine if table exists by checking if data source returned a value
  table_exists = try(data.aws_dynamodb_table.terraform_locks.name != "", false)
  
  # Determine if KMS key exists by checking if data source returned a value
  kms_key_exists = try(data.aws_kms_alias.terraform_key.name != "", false)
  
  # Only create bucket if it doesn't exist
  create_bucket = !local.bucket_exists
  
  # Only create DynamoDB table if it doesn't exist
  create_table = !local.table_exists
  
  # Only create KMS key if it doesn't exist
  create_kms_key = !local.kms_key_exists
} 