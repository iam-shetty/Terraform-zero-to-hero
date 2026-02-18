
/*
# ==============================
# EC2 Outputs
# ==============================
output "ec2_instance_id" {
  description = "ID of the EC2 instance created"
  value       = aws_instance.web-server.id
}
output "ec2-public-ip" {
    description = "Public IP address of the EC2 instance"
    value       = aws_instance.web-server.public_ip
  
}

# ==============================
# S3 Outputs
# ==============================
output "s3-bucket" {
    description = "critical bucket name"
    value=aws_s3_bucket.critical_data.bucket
  
}

# ==============================
# Auto Scaling Outputs
# ==============================

output "auto-scale" {
    description = "name of the autoscaling group (ignore change example)"
    value=aws_autoscaling_group.AG.name
  
}
output "AG-Minsize" {
    description = "Min size of the autoscaling group (ignore change example)"
    value=aws_autoscaling_group.AG.min_size
  
}
output "AG-Maxsize" {
    description = "Max size of the autoscaling group (ignore change example)"
    value=aws_autoscaling_group.AG.max_size
  
}
output "AG-DesiredCapacity" {
    description = "Desired capacity of the autoscaling group (ignore change example)"
    value=aws_autoscaling_group.AG.desired_capacity
  
}
*/
output "CurrentRegion" {
    description = "Current AWS region where resources are being created"
    value       = data.aws_region.current.name
  
}
output "allowedregions" {
    description = "List of allowed regions for resource creation"
    value       = var.allowed_regions
  
}