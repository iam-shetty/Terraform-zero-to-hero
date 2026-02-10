variable "instance_type" {
  description = "Type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"

}
variable "count1" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1
}
variable "monitoring" {
  description = "Enable detailed monitoring for the EC2 instance"
  type        = bool
  default     = true

}
variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true

}
variable "region" {
  type        = string
  description = "the aws region"
  default     = "us-east-1"
}
variable "server_config" {
  type = object({
    name           = string
    instance_type  = string
    monitoring     = bool
    storage_gb     = number
    backup_enabled = bool
  })
  description = "Complete server configuration object"
  default = {
    name           = "web-server"
    instance_type  = "t2.micro"
    monitoring     = true
    storage_gb     = 20
    backup_enabled = false
  }
  # KEY BENEFITS:
  # - Self-documenting structure
  # - Type safety for each attribute
  # - Access: var.server_config.name, var.server_config.monitoring
  # - All attributes must be provided (unless optional)
}

variable "network_config" {
  type        = tuple([string, string, number])
  description = "Network Configuration (VPC CIDR, Subnet CIDR, Port Number)"
  default     = ["10.0.0.0/16", "10.0.1.0/24", 80]
  # CRITICAL RULES:
  # - Position 0 must be string (VPC CIDR)
  # - Position 1 must be string (subnet CIDR)  
  # - Position 2 must be number (port)
  # - Cannot add/remove elements - length is fixed
  # Access: var.network_config[0], var.network_config[1], var.network_config[2]
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "list of allowed cidr blocks for security group"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  # Access: var.allowed_cidr_blocks[0] = "10.0.0.0/8"
  # Can have duplicates: ["10.0.0.0/8", "10.0.0.0/8"] is valid
}

# Set type - IMPORTANT: No duplicates allowed, order doesn't matter
variable "availability_zones" {
  type        = set(string)
  description = "set of availability zones (no duplicates)"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  # KEY DIFFERENCE FROM LIST:
  # - Automatically removes duplicates
  # - Order is not guaranteed
  # - Cannot access by index like set[0] - need to convert to list first
}

variable "storage_size" {
  type        = number
  description = "the storage size for ec2 instance in GB"
  default     = 8
}

# Map type - IMPORTANT: Key-value pairs, keys must be unique
variable "instance_tags" {
  type        = map(string)
  description = "tags to apply to the ec2 instances"
  default = {
    "Environment" = "dev"
    "Project"     = "terraform-course"
    "Owner"       = "devops-team"
  }
  # Access: var.instance_tags["Environment"] = "dev"
  # Keys are always strings, values must match the declared type
}
variable "s3_bucket_names" {
  type        = list(string)
  description = "List of S3 bucket names for count example"
  default     = ["tf-day07-count-bucket-1", "tf-day07-count-bucket-2", "tf-day07-count-bucket-3"]

}

#set type for for_each example
variable "s3_bucket_set" {
  type        = set(string)
  description = "Set of S3 bucket names for for_each example"
  default = [
    "tf-day07-foreach-bucket-a",
    "tf-day07-foreach-bucket-b",
    "tf-day07-foreach-bucket-c"
  ]
}

# map type

variable "resource_tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default = {
    "Environment" = "staging"
    "Project"     = "terraform"
    "Owner"       = "devops-team"
  }

}
variable "Environment" {
  type        = string
  description = "The environment for resource tagging"
  default     = "staging"

}



