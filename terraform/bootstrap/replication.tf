# Set up replication configuration for cross-region replication
# This addresses CKV_AWS_144 requirement
resource "aws_s3_bucket_replication_configuration" "terraform_state" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "terraform-state-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      storage_class = "STANDARD"
    }
  }

  # Replication requires versioning to be enabled first
  depends_on = [aws_s3_bucket_versioning.terraform_state]
}

# Create replica bucket in another region for disaster recovery
resource "aws_s3_bucket" "replica" {
  count    = local.create_bucket ? 1 : 0
  provider = aws.replica_region
  bucket   = "terraform-state-replica-lab2-group8"

  tags = {
    Name        = "Terraform State Replica Bucket"
    Environment = "dev"
  }
}

# Enable versioning on replica bucket
resource "aws_s3_bucket_versioning" "replica" {
  count    = local.create_bucket ? 1 : 0
  provider = aws.replica_region
  bucket   = aws_s3_bucket.replica[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to replica bucket
resource "aws_s3_bucket_public_access_block" "replica" {
  count    = local.create_bucket ? 1 : 0
  provider = aws.replica_region
  bucket   = aws_s3_bucket.replica[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  count = local.create_bucket ? 1 : 0
  name  = "terraform-state-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for replication with required permissions
resource "aws_iam_policy" "replication" {
  count = local.create_bucket ? 1 : 0
  name  = "terraform-state-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.terraform_state[0].arn
        ]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.terraform_state[0].arn}/*"
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.replica[0].arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "replication" {
  count      = local.create_bucket ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
} 