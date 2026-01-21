variable "instance_type" {
    description = "The type of instance to create."
    type        = string
    default     = "t3.micro"
  
}
variable "key_name" {
    description = "The name of the SSH key pair."
    type        = string
    
  
}
variable "private_key_path" {
    description = "The path to the private key file."
    type        = string
  
}
variable "ssh_user" {

    description = "The SSH user for the AMI(Default for Ubuntu is ubuntu)."
    type        = string
    default     = "ubuntu"
  
}