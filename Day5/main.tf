resource "aws_key_pair" "example" {

  key_name   = "terraform-demo-shetty"
  public_key = file("/home/shetty/.ssh/id_rsa.pub")
  
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
}
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
  
}
resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.my_vpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id 
    }
}
resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "webSg" {
    name = "web"
    vpc_id = aws_vpc.my_vpc.id
    ingress {
      description = "HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0 
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
     tags = {
      Name = "web-sg"
    }
}
resource "aws_instance" "server" {
    ami           = "ami-0ecb62995f68bb549"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.sub1.id
    vpc_security_group_ids = [aws_security_group.webSg.id]
    key_name = aws_key_pair.example.key_name

    tags = {
      Name = "Terraform-Demo-Instance"
    }
    connection {
      type = "ssh"
      user  = "ubuntu" 
      agent = true
      host = self.public_ip 
      }
      //File Provisioner to copy file from local to remote
    provisioner "file" {
      source      = "app.py"
      destination = "/home/ubuntu/app.py"
    }
    //Remote-exec provisioner to run commands on remote server
    provisioner "remote-exec" {
      inline = [
        "echo 'Hello from Terraform provisioner'",
        "sudo apt-get update -y",
        "sudo apt-get install python3-pip -y",  
        "cd /home/ubuntu",
        "sudo pip3 install flask",
        "sudo python3 app.py &",
      ]
    }                            


}   
