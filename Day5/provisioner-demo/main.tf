terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# EC2 instance used for provisioner demos.
# Each provisioner block is included below but wrapped in block comments (/* ... */).
# For the demo, uncomment one provisioner block at a time, then `terraform apply`.

data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical
    
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
      name = "virtualization-type"
        values = ["hvm"]
    }  
}

resource "aws_security_group" "sg" {
    name = "provisioner-demo-sg"
    description = "Security group for provisioner demo"
    ingress = [{
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false
    }]
    egress = [{
        description      = "Allow all outbound"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false
    }]

    tags = {
        Name = "provisioner-demo-sg"
    }
}

resource "aws_instance" "provisioner_demo" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]

    tags = {
        Name = "provisioner-demo-instance"
    }
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }

    # Wait for SSH to be ready before running provisioners
    /*
    provisioner "remote-exec" {
      inline = ["echo 'SSH is ready'"]
    }
    */

    /* Example of a remote-exec provisioner */
    /*
    ---------------------------------------------------
    Provisioner 1: local-exec to run a local script

  - Runs on the machine where you run Terraform (your laptop/CI agent).
  - Useful for local tasks, logging, calling local scripts, etc.
  - To demo: uncomment this block, then run `terraform apply`.
    ---------------------------------------------------
    */
   #provisioner "local-exec" {
    #  command = "echo 'Local-exec: created instance ${self.id} with IP ${self.public_ip}'"
   # }


    
    /*
    ---------------------------------------------------
    Provisioner 2: remote-exec to run a local script
  - Runs commands on the remote instance over SSH.
  - Requires SSH access (security group + key pair + reachable IP).
  - To demo: uncomment this block, ensure `var.private_key_path` is correct, then run `terraform apply`.
  ------------------------------------------------------------------
  */

    /*
        provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y",
            "echo 'Hello from remote-exec' | sudo tee /tmp/remote_exec.txt",
        ]

        
    }
    */
    

   
   
    /*
  ------------------------------------------------------------------
  Provisioner 3: file + remote-exec
  - Copies a script (scripts/welcome.sh) to the instance, then executes it.
  - Good pattern for more complex bootstrapping when script files are preferred.
  - To demo: uncomment both the file provisioner and the remote-exec block below.
  ------------------------------------------------------------------
  */
    /*
    provisioner "file" {
        source      = "${path.module}/scripts/welcome.sh"
        destination = "/tmp/welcome.sh"

        }
    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /tmp/welcome.sh",
            "sudo /tmp/welcome.sh",
        ]
        }
    */
  
}