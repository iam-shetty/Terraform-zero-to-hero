provider "aws" {
    region = "us-east-1"    
  
}
# Data source to get the existing VPC
data "aws_vpc" "shared_vpc" {
    filter {
        name = "tag:Name"
        values = ["Shared_VPC"]
    }
  
}
# Data source to get the existing VPC
data "aws_subnet" "shared_subnet" {
    filter {
        name = "tag:Name"
        values = ["shared-primary-subnet"]
    }
    vpc_id = data.aws_vpc.shared_vpc.id
  
}
# Data source to get the latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
    most_recent = true
    filter {            
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical 
}
# Create an EC2 instance in the existing subnet
resource "aws_instance" "my_instance" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.shared_subnet.id
    private_ip = "10.0.0.50"
    tags = {
        Name = "MyInstance"
    }
}                         