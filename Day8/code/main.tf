    # ==============================
# Data Sources
# ==============================
# Get the latest Amazon Linux 2 AMI ID
data "aws_ami" "ubuntu" {
    most_recent = true
   filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical)]
}

#get thge cuurent AWS region
data "aws_region" "current" {}

#GET THE AVAILABILITY ZONES IN THE CURRENT REGION  
data "aws_availability_zones" "available" {
  state = "available"
  
}
# Data source to get the existing VPC
data "aws_vpc" "vpc_name" {

  filter {
    name = "tag:Name"
    values = ["default"]
  }
}
data "aws_subnet" "shared_subnet" {
  filter {
    name = "tag:Name"
    values = ["my-subnet-a"]
  }
  vpc_id = data.aws_vpc.vpc_name.id
  
}


# ==============================
# Example 1: create_before_destroy
# Use Case: EC2 instance that needs zero downtime during updates
# ==============================

/*resource "aws_instance" "web-server" {
    ami=data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    subnet_id = data.aws_subnet.shared_subnet.id
    

    tags = merge(
        var.resource_tags,
        {
            Name = "WebServer-${var.instance_type}"
            Demo = "CreateBeforeDestroy"
        }
    )

    #Lifecycle Rule: Create new instance before destroying the old one
  # This ensures zero downtime during instance updates (e.g., changing AMI or instance type)
    lifecycle {
      create_before_destroy = true
    }
}

# ==============================
# Example 2: prevent_destroy
# Use Case: Critical S3 bucket that should never be accidentally deleted
# ==============================
resource "aws_s3_bucket" "critical_data" {
    bucket="my-critical-project-data-${var.Environment}-${data.aws_region.current.region}"
    tags = merge(
        var.resource_tags,
        {
            Name = "CriticalDataBucket"
            Demo = "PreventDestroy"
            DataType = "Critical"
            compliance = "required"
        }
    )

    # Lifecycle Rule: Prevent accidental deletion of this bucket
  # Terraform will throw an error if you try to destroy this resource
  # To delete: Comment out prevent_destroy first, then run terraform apply
    lifecycle {
      prevent_destroy = false
    }
  
}

# Enable versioning on the critical bucket to protect against accidental overwrites/deletions of objects
resource "aws_s3_bucket_versioning" "criticl_data" {
bucket = aws_s3_bucket.critical_data.id
versioning_configuration {
    status = "Enabled"
  }
}

# ==============================
# Example 3: ignore_changes
# Use Case: Auto Scaling Group where capacity is managed externally
# ==============================

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "app_server" {
  name_prefix   = "app-server-lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"
    tags = merge(
        var.resource_tags,
        {
            Name = "AppServerLC"
            Demo = "IgnoreChanges"
        }
    )
  }
}

resource "aws_autoscaling_group" "AG" {
    name                      = "app-server-asg"
    max_size                  = 5
    min_size                  = 1
    desired_capacity          = 2
    health_check_type = "EC2"
    vpc_zone_identifier = [data.aws_subnet.shared_subnet.id]
    
    launch_template {
        id      = aws_launch_template.app_server.id
        version = "$Latest"
    }
    tag {
      key = "Name"
      value = "App Server AG"
      propagate_at_launch = true
    }
     tag {
    key                 = "Demo"
    value               = "ignore_changes"
    propagate_at_launch = false
  }
    
    # Lifecycle Rule: Ignore changes to desired_capacity
    # This allows external scaling actions (e.g., manual scaling or scaling policies) without Terraform trying to revert them
    # This is useful when auto-scaling policies or external systems modify capacity
  # Terraform won't try to revert capacity changes made outside of Terraform
    lifecycle {
        ignore_changes = [
            desired_capacity,
            # Also ignore load_balancers if added later by other processes
            ]
    }
  
}
*/


# ==============================
# Example 4: precondition
# Use Case: Ensure we're deploying in an allowed region
# ==============================

resource "aws_s3_bucket" "region_check" {
  bucket="region-bucket-check-${var.Environment}-${data.aws_region.current.region}"  

  tags = merge(
        var.resource_tags,
        {
            Name = "RegionCheckBucket"
            Demo = "Precondition"
        }
    )
    # Lifecycle Rule: Validate region before creating resource
  # This prevents resource creation in unauthorized regions
  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.region)
      error_message = "ERROR: This resource can only be created in allowed regions: ${join(", ", var.allowed_regions)}. Current region: ${data.aws_region.current.region}"
    }
  }
}


# ==============================
# Example 5: postcondition
# Use Case: Ensure S3 bucket has required tags after creation
# ==============================

resource "aws_s3_bucket" "compliance_bucket" {
  bucket="compliance-bucket-${var.Environment}-${data.aws_region.current.region}"  

  tags = merge(
        var.resource_tags,
        {
            Name = "ComplianceBucket"
            Demo = "Postcondition"
            Compliance = "soc2"
        }
  )
        
        # Lifecycle Rule: Validate bucket has required tags after creation
  # This ensures compliance with organizational tagging policies
  lifecycle {
    postcondition {
        condition = contains(keys(self.tags),"Compliance")      
        error_message = "ERROR: Bucket must have a 'Compliance' tag for audit purposes!"
    }
     postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
    
  }
    
  }

  # ==============================
# Example 6: replace_triggered_by
# Use Case: Replace EC2 instances when security group changes
# ==============================
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.vpc_name.id
  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  

}
ingress{
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  description = "Allow HTTPS traffic from anywhere"
}
egress{
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
description = "Allow all outbound traffic"
}
tags=merge(
        var.resource_tags,
        {
            Name = "WebServerSG"
            Demo = "ReplaceTriggeredBy"
        }
    )

}

# EC2 Instance that gets replaced when security group changes
resource "aws_instance" "app-with-sg" {
  ami=data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.shared_subnet.id
  security_groups = [aws_security_group.web_sg.name]

  tags = merge(
        var.resource_tags,
        {
            Name = "AppWithSG"
            Demo = "ReplaceTriggeredBy"
        }
    )
    # Lifecycle Rule: Replace instance when security group changes
  # This ensures the instance is recreated with new security rules
  lifecycle {
    replace_triggered_by = [ aws_security_group.web_sg.id ]
  }
  
}

# ==============================
# Example 7: Multiple S3 Buckets with create_before_destroy
# Use Case: Managing multiple buckets from a set
# ==============================

resource "aws_s3_bucket" "app_buckets" {
  for_each = var.s3_bucket_names

  bucket = "${each.value}-${var.Environment}"

  tags = merge(
    var.resource_tags,
    {
      Name   = each.value
      Demo   = "for_each_with_lifecycle"
      Bucket = each.key
    }
  )

  # Lifecycle Rule: Create new bucket before destroying old one
  # Useful when renaming buckets or migrating data
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore ACL changes if managed by another process
      # acl,
    ]
  }
}

# ==============================
# Example 8: Combining Multiple Lifecycle Rules
# Use Case: DynamoDB table with comprehensive protections (SIMPLE EXAMPLE)
# ==============================

# This example shows how to combine multiple lifecycle rules on a single resource
# DynamoDB is used here because it's simple and doesn't require VPC setup

resource "aws_dynamodb_table" "critical_app_data" {
  name         = "${var.Environment}-app-data-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.resource_tags,
    {
      Name        = "Critical Application Data"
      Demo        = "multiple_lifecycle_rules"
      DataType    = "Critical"
      Environment = var.Environment
    }
  )

  # Multiple Lifecycle Rules Combined for Production Protection
  lifecycle {
    # Rule 1: Prevent accidental deletion
    # This protects the table from being destroyed accidentally
    # prevent_destroy = true  # COMMENTED OUT TO ALLOW DESTRUCTION

    # Rule 2: Create new resource before destroying old one
    # Ensures zero downtime if table needs to be recreated
    create_before_destroy = true

    # Rule 3: Ignore changes to certain attributes
    # Allow AWS to manage read/write capacity for auto-scaling
    ignore_changes = [
      # Ignore read/write capacity if using auto-scaling
      # read_capacity,
      # write_capacity,
    ]

    # Rule 4: Validate before creation
    precondition {
      condition     = contains(keys(var.resource_tags), "Environment")
      error_message = "Critical table must have Environment tag for compliance!"
    }

    # Rule 5: Validate after creation
    postcondition {
      condition     = self.billing_mode == "PAY_PER_REQUEST" || self.billing_mode == "PROVISIONED"
      error_message = "Billing mode must be either PAY_PER_REQUEST or PROVISIONED!"
    }
  }
}

# ==============================
# Note: RDS Example (Too Complex for Simple Demo)
# ==============================
# RDS requires VPC, subnets, security groups, etc.
# For a simple lifecycle demo, the above DynamoDB example is better
# If you need RDS lifecycle examples, set up VPC resources first
# 
# See the documentation for production RDS patterns with lifecycle rules






