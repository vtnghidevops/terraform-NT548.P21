terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-lab2-group8"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks-lab2-group8"
  }
}