resource "aws_kms_key" "dynamodb_key" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  # KMS key policy
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-policy-dynamodb",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key for DynamoDB",
        Effect = "Allow",
        Principal = {
          Service = "dynamodb.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "dynamodb-cmk"
    Environment = "dev"
  }
}

resource "aws_kms_alias" "dynamodb_key_alias" {
  name          = "alias/dynamodb-table-key"
  target_key_id = aws_kms_key.dynamodb_key.key_id
}

# Get current AWS account ID
data "aws_caller_identity" "current" {} 