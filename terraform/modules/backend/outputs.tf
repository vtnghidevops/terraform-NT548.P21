output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
} 