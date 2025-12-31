terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# backend configuration
terraform {
    backend "s3" {
    bucket = "terraform-state-1767168310"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true 
}
}
# Simple test resource to verify remote backend
resource "aws_s3_bucket" "test-backend"{
    bucket="test-remote-backend-${random_string.bucket_suffix.result}"

    tags={
        Name="Test Backend Bucket"
        Environment="Dev"
    }
    }
    resource "random_string" "bucket_suffix" {
      length = 8
      upper  = false
      special = false
      
    }

