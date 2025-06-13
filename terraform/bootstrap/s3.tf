# Check if S3 bucket for Terraform state exists
data "aws_s3_bucket" "terraform_state_exists" {
  count  = 1
  bucket = "terraform-state-bucket-lab2-group8"

  lifecycle {
    ignore_changes = all
  }
}

locals {
  s3_bucket_exists = length(data.aws_s3_bucket.terraform_state_exists) > 0 ? true : false
}

# Create S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = "terraform-state-bucket-lab2-group8"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
  
  # Prevent bucket deletion if it exists
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# Enable versioning for S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with KMS for S3 bucket
resource "aws_kms_key" "terraform_state_key" {
  count                   = local.s3_bucket_exists ? 0 : 1
  description             = "KMS key for Terraform state bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.s3_bucket_exists ? null : aws_kms_key.terraform_state_key[0].arn
      sse_algorithm     = local.s3_bucket_exists ? "AES256" : "aws:kms"
    }
  }
}

# Block public access for S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable access logging for S3 bucket
resource "aws_s3_bucket" "access_logs" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = "terraform-state-access-logs-lab2-group8"

  tags = {
    Name        = "Terraform State Access Logs"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_logging" "terraform_state_logging" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id

  target_bucket = local.s3_bucket_exists ? "terraform-state-access-logs-lab2-group8" : aws_s3_bucket.access_logs[0].id
  target_prefix = "terraform-state-logs/"
}

# Add lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Enable event notifications
resource "aws_s3_bucket_notification" "terraform_state_notification" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id

  topic {
    topic_arn     = local.s3_bucket_exists ? aws_sns_topic.terraform_state_topic[0].arn : aws_sns_topic.terraform_state_topic[0].arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".tfstate"
  }
}

resource "aws_sns_topic" "terraform_state_topic" {
  count = local.s3_bucket_exists ? 0 : 1
  name  = "terraform-state-topic"
}

# Enable cross-region replication
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = local.s3_bucket_exists ? "terraform-state-bucket-lab2-group8" : aws_s3_bucket.terraform_state[0].id
  role   = local.s3_bucket_exists ? aws_iam_role.replication[0].arn : aws_iam_role.replication[0].arn

  rule {
    id     = "terraform-state-replication"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = local.s3_bucket_exists ? aws_s3_bucket.terraform_state_replica[0].arn : aws_s3_bucket.terraform_state_replica[0].arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state_versioning]
}

resource "aws_s3_bucket" "terraform_state_replica" {
  count  = local.s3_bucket_exists ? 0 : 1
  bucket = "terraform-state-replica-lab2-group8"

  tags = {
    Name        = "Terraform State Replica"
    Environment = "dev"
  }
}

resource "aws_iam_role" "replication" {
  count = local.s3_bucket_exists ? 0 : 1
  name  = "terraform-state-replication-role"

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
  count = local.s3_bucket_exists ? 0 : 1
  name  = "terraform-state-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = local.s3_bucket_exists ? ["arn:aws:s3:::terraform-state-bucket-lab2-group8"] : [aws_s3_bucket.terraform_state[0].arn]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Effect   = "Allow",
        Resource = local.s3_bucket_exists ? ["arn:aws:s3:::terraform-state-bucket-lab2-group8/*"] : ["${aws_s3_bucket.terraform_state[0].arn}/*"]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Effect   = "Allow",
        Resource = local.s3_bucket_exists ? ["arn:aws:s3:::terraform-state-replica-lab2-group8/*"] : ["${aws_s3_bucket.terraform_state_replica[0].arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = local.s3_bucket_exists ? 0 : 1
  role       = local.s3_bucket_exists ? "terraform-state-replication-role" : aws_iam_role.replication[0].name
  policy_arn = local.s3_bucket_exists ? aws_iam_policy.replication[0].arn : aws_iam_policy.replication[0].arn
}

