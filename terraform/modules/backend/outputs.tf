output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_key.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_key.arn
} 