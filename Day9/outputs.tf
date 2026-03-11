# ==============================================================================
# EXAMPLE 1 OUTPUT: CONDITIONAL EXPRESSION
# ==============================================================================
# Uncomment when testing Example 1
output "conditional_instance_type" {
    value = aws_instance.conditional_Example.instance_type
    description = "The instance type chosen based on environment"
}
output "conditional_instance_id" {
    value = aws_instance.conditional_Example.id
    description = "Instance of conditional id"
  
}

# ==============================================================================
# EXAMPLE 2 OUTPUT: DYNAMIC BLOCK
# ==============================================================================
# Uncomment when testing Example 2

output "dynamic-sg-id" {
    value = aws_security_group.dynamic-sg.id
    description = "ID of the security group with dynamic block"
}
output "security-group-rules-count" {
    description = "No of ingress rules created"
    value = length(aws_security_group.dynamic-sg.ingress)
}

# ==============================================================================
# EXAMPLE 3 OUTPUTS: SPLAT EXPRESSION
# ==============================================================================
# Uncomment when testing Example 3

 output "all_instance_ids" {
 description = "All instance IDs using splat expression [*]"
   value       = aws_instance.spalt_example[*].id
 }

 output "all_private_ips" {
   description = "All private IPs using splat expression [*]"
   value       = aws_instance.spalt_example[*].private_ip
 }