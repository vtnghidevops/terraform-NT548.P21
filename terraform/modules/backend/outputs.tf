output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_dynamodb_key_id" {
  description = "The ID of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_key.id
}

output "kms_dynamodb_key_arn" {
  description = "The ARN of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_key.arn
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.arn
} 