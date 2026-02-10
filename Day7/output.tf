# =============================================================================
# Output Variables - Demonstrating different output patterns with count and for_each
# =============================================================================

# -----------------------------------------------------------------------------
# Outputs for COUNT-based resources
# -----------------------------------------------------------------------------

#using splat expressiion to get all the bucket names
output "s3_bucket_names_count" {
  description = "Name of the s3 buckets created using count meta-argument(using splat expression)"
  value       = aws_s3_bucket.example_count[*].id

}
# Using splat expression to get all bucket ARNs
output "s3_bucket_arns_count" {
  description = "ARNs of S3 buckets created with count"
  value       = aws_s3_bucket.example_count[*].arn
}

# -----------------------------------------------------------------------------
# Outputs for FOR_EACH-based resources
# -----------------------------------------------------------------------------

# Using for loop to get bucket names from for_each

output "s3_bucket_names_foreach" {
  description = "Name of the s3 buckets created using for_each meta-argument(using for loop)"
  value       = [for bucket in aws_s3_bucket.example_for_each : bucket.id]

}

#creating a map output for bucket names and ARNs
output "s3_bucket_details_foreach" {
  description = "Map of bucket names and ARNs for buckets created with for_each"
  value = {
    for key, bucket in aws_s3_bucket.example_for_each :
    key => {
      name = bucket.id,
      arn  = bucket.arn
    }

  }
}

# -----------------------------------------------------------------------------
# Outputs for meta-argument examples
# -----------------------------------------------------------------------------

# depends_on example outputs

output "primary_bucket_id" {
  description = "ID of the primary bucket that other buckets depend on"
  value       = aws_s3_bucket.primary.id

}
output "DependentBucket" {
  description = "ID of the dependent bucket that relies on the primary bucket"
  value       = aws_s3_bucket.dependent.id

}
output "LifecycleBucket" {
  description = "ID of the bucket with lifecycle rules"
  value       = aws_s3_bucket.lifecycle_example.id



}
output "total_no_of_buckets" {
  description = "Total number of buckets created across all examples"
  value       = length(aws_s3_bucket.example_count) + length(aws_s3_bucket.example_for_each) + 3 # +2 for primary and dependent buckets

} 