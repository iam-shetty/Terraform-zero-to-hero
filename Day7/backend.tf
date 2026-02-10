terraform {
  backend "s3" {
    bucket       = "terraform-state-1770291329" # Can be passed via `-backend-config="bucket=<bucket name>"` in the `init` command
    key          = "dev/terraform.tfstate"      # Can be passed via `-backend-config="bucket=<bucket name>"` in the `init` command
    region       = "us-east-1"                  # Can be passed via `-backend-config="bucket=<bucket name>"` in the `init` command
    use_lockfile = true
    encrypt      = true

    # Optional: DynamoDB table for state locking
    # dynamodb_table = "terraform-state-lock"  # Can be passed via `-backend-config="dynamodb_table=<table name>"` in the `init` command
    # encrypt        = true
  }
}