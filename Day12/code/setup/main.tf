# In a real-world scenario, these resources would already exist.
# We are creating them here to simulate that environment.


provider "aws" {
  # Configuration options
  region = "us-east-1"

}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Shared_VPC"
  }

}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "shared-primary-subnet"

  }
}
