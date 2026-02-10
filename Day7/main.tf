# =============================================================================
# Day 08: Meta-Arguments in Terraform (count and for_each)
# =============================================================================
# This file demonstrates the use of meta-arguments:
# 1. count - Creates multiple instances using index-based iteration
# 2. for_each - Creates multiple instances using map/set iteration
# =============================================================================

# -----------------------------------------------------------------------------
# Example 1: Using COUNT meta-argument with S3 buckets
# -----------------------------------------------------------------------------
# count is useful when you want to create multiple identical resources
# Access individual instances using count.index

resource "aws_s3_bucket" "example_count" {
  count  = length((var.s3_bucket_names))
  bucket = var.s3_bucket_names[count.index]

  tags = {
    Name        = var.s3_bucket_names[count.index]
    Environment = var.Environment
    Index       = count.index
    ManagedBy   = "Terraform"
  }

}


# -----------------------------------------------------------------------------
# Example 2: Using FOR_EACH meta-argument with S3 buckets
# -----------------------------------------------------------------------------
# for_each is useful when you want to create resources from a map or set
# Access individual instances using each.key and each.value
# Note: for_each requires a map or set, not a list

resource "aws_s3_bucket" "example_for_each" {
  for_each = var.s3_bucket_set
  bucket   = each.value

  tags = {
    Name        = each.value
    Environment = var.Environment
    BucketType  = "foreach-example"
    ManagedBy   = "terraform"
  }

}


# -----------------------------------------------------------------------------
# Example 3: DEPENDS_ON meta-argument
# -----------------------------------------------------------------------------
# depends_on is used to explicitly specify dependencies between resources
# Terraform automatically handles most dependencies, but sometimes you need explicit control

# First, create a bucket that will be used as a dependency

resource "aws_s3_bucket" "primary" {
  bucket = "tf-day07-primary-bucket-${var.Environment}"

  tags = {
    Name        = "PrimaryBucket"
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }

}

# Now create another bucket that depends on the primary bucket
resource "aws_s3_bucket" "dependent" {
  bucket = "tf-day07-dependent-bucket-${var.Environment}"

  tags = {
    Name        = "DependentBucket"
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
  # Explicit dependency - this will be created AFTER primary bucket
  depends_on = [aws_s3_bucket.primary]

}


# -----------------------------------------------------------------------------
# Example 4: LIFECYCLE meta-argument
# -----------------------------------------------------------------------------
# lifecycle controls how Terraform handles resource creation/destruction
# Common use cases: prevent_destroy, create_before_destroy, ignore_changes

resource "aws_s3_bucket" "lifecycle_example" {
  bucket = "tf-day07-lifecycle-bucket-${var.Environment}"

  tags = {
    Name        = "LifecycleBucket"
    Environment = var.Environment
    ManagedBy   = "Terraform"
    createdDate = timestamp() # This tag will be ignored in lifecycle rules
  }
  #lifecycle rules
  lifecycle {
    prevent_destroy       = false # set to true to prevent accidental deletion of the buckets in Production environment
    create_before_destroy = true  # ensures new bucket is created before old one is destroyed during updates
    ignore_changes = [
      tags["CreatedDate"],
    ] # ignore changes to tags to prevent unnecessary updates
  }

}