# Terraform Bootstrap Module

This module creates the required infrastructure for Terraform state management, including:

- S3 bucket for storing Terraform state files
- DynamoDB table for state locking
- KMS key for encryption

## Security Features

This module implements the following security best practices:

1. **KMS Encryption**

   - Uses a Customer Managed Key (CMK) for encryption of both S3 and DynamoDB
   - Enables key rotation for the KMS key

2. **S3 Bucket Security**

   - Enables access logging to a separate bucket
   - Implements bucket versioning
   - Blocks all public access
   - Configures server-side encryption with KMS
   - Sets up lifecycle policies for cost optimization
   - Enables event notifications for monitoring
   - Implements cross-region replication for disaster recovery

3. **DynamoDB Security**
   - Enables point-in-time recovery for backups
   - Configures KMS encryption for table data

## Usage

This module is designed to be run before the main Terraform configuration. It checks if the resources already exist, and only creates them if needed.

```hcl
module "bootstrap" {
  source = "./bootstrap"
}

# In main Terraform configuration:
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-lab2-group8"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-lab2-group8"
    encrypt        = true
  }
}
```

## Outputs

- `bucket_name`: Name of the S3 bucket for state storage
- `table_name`: Name of the DynamoDB table for state locking
- `kms_key_id`: ID of the KMS key used for encryption

## Files Structure

- `providers.tf` - AWS provider configuration
- `data.tf` - Data sources to check existing resources
- `locals.tf` - Local variables and conditional logic
- `kms.tf` - KMS key resources
- `s3.tf` - S3 bucket for state storage and access logs
- `replication.tf` - Cross-region replication configuration
- `dynamodb.tf` - DynamoDB table for state locking
- `outputs.tf` - Output values
