# Create S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
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

# Create S3 bucket for access logs
# This addresses CKV_AWS_18 requirement for access logging
resource "aws_s3_bucket" "access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = "terraform-state-logs-lab2-group8"

  tags = {
    Name        = "Terraform State Logs Bucket"
    Environment = "dev"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

# Enable server-side encryption for logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to logs bucket
resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable access logging for state bucket
# This addresses CKV_AWS_18 requirement
resource "aws_s3_bucket_logging" "terraform_state" {
  count         = local.create_bucket ? 1 : 0
  bucket        = aws_s3_bucket.terraform_state[0].id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "terraform-state-logs/"
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure server-side encryption for state bucket with KMS
# This addresses CKV_AWS_145 requirement
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_exists ? data.aws_kms_alias.terraform_key.target_key_id : aws_kms_key.terraform_key[0].key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

# Configure lifecycle policy for state bucket
# This addresses CKV2_AWS_61 requirement
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    id     = "state-retention"
    status = "Enabled"

    # Move older versions to cheaper storage after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    # Move older versions to archive storage after 60 days
    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    # Delete older versions after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Set up event notifications for S3 bucket
# This addresses CKV2_AWS_62 requirement
resource "aws_s3_bucket_notification" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  topic {
    topic_arn     = aws_sns_topic.s3_notifications[0].arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".tfstate"
  }
}

# Create SNS topic for S3 notifications
resource "aws_sns_topic" "s3_notifications" {
  count  = local.create_bucket ? 1 : 0
  name   = "terraform-state-notifications"
  
  kms_master_key_id = local.kms_key_exists ? data.aws_kms_alias.terraform_key.target_key_id : aws_kms_key.terraform_key[0].key_id
} 