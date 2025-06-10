# Output status message showing what resources were created or reused
output "status" {
  value = <<EOT
S3 Bucket Status: ${local.bucket_exists ? "Using existing bucket" : "Created new bucket"}
DynamoDB Table Status: ${local.table_exists ? "Using existing table" : "Created new table"}
KMS Key Status: ${local.kms_key_exists ? "Using existing KMS key" : "Created new KMS key"}
EOT
}

# Output bucket name for reference in main Terraform configuration
output "bucket_name" {
  value = local.bucket_exists ? data.aws_s3_bucket.terraform_state.bucket : (local.create_bucket ? aws_s3_bucket.terraform_state[0].bucket : "")
}

# Output table name for reference in main Terraform configuration
output "table_name" {
  value = local.table_exists ? data.aws_dynamodb_table.terraform_locks.name : (local.create_table ? aws_dynamodb_table.terraform_locks[0].name : "")
}

# Output KMS key ID for reference in main Terraform configuration
output "kms_key_id" {
  value = local.kms_key_exists ? data.aws_kms_alias.terraform_key.target_key_id : (local.create_kms_key ? aws_kms_key.terraform_key[0].key_id : "")
} 