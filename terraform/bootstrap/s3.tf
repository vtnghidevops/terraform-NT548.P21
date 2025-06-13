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

# Enable versioning for S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with KMS for S3 bucket
resource "aws_kms_key" "terraform_state_key" {
  description             = "KMS key for Terraform state bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access for S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable access logging for S3 bucket
resource "aws_s3_bucket" "access_logs" {
  bucket = "terraform-state-access-logs-lab2-group8"

  tags = {
    Name        = "Terraform State Access Logs"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_logging" "terraform_state_logging" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "terraform-state-logs/"
}

# Add lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Enable event notifications
resource "aws_s3_bucket_notification" "terraform_state_notification" {
  bucket = aws_s3_bucket.terraform_state.id

  topic {
    topic_arn     = aws_sns_topic.terraform_state_topic.arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".tfstate"
  }
}

resource "aws_sns_topic" "terraform_state_topic" {
  name = "terraform-state-topic"
}

# Enable cross-region replication
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  bucket = aws_s3_bucket.terraform_state.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "terraform-state-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.terraform_state_replica.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state_versioning]
}

resource "aws_s3_bucket" "terraform_state_replica" {
  bucket = "terraform-state-replica-lab2-group8"

  tags = {
    Name        = "Terraform State Replica"
    Environment = "dev"
  }
}

resource "aws_iam_role" "replication" {
  name = "terraform-state-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "replication" {
  name = "terraform-state-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [aws_s3_bucket.terraform_state.arn]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Effect   = "Allow",
        Resource = ["${aws_s3_bucket.terraform_state.arn}/*"]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Effect   = "Allow",
        Resource = ["${aws_s3_bucket.terraform_state_replica.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

