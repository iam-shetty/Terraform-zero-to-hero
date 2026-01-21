output "instance_id" {
    description = "The ID of the provisioner demo EC2 instance."
    value       = aws_instance.provisioner_demo.id
  
}
output "public_ip" {
    description = "The public IP address of the provisioner demo EC2 instance."
    value       = aws_instance.provisioner_demo.public_ip
  
}