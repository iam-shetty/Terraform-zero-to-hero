terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.7.0"
    }
  }
  required_version = ">=1.0"
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

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
    owners = ["099720109477"] # Canonical)]
        
  
}

resource "aws_instance" "my_instance" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.shared_subnet.id
    tags = {
        Name = "MyInstance" 
    }
  
}
