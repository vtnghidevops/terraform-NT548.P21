provider "aws" {
  region = "us-east-1"
}

# Secondary provider for cross-region replication
provider "aws" {
  alias  = "replica_region"
  region = "us-west-2"
} 