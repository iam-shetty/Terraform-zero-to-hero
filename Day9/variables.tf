variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"

}
variable "ingress_rule" {
  description = "list of ingress rules for dynamic security group"
  type =list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [ 
    {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "http"

    
  },
  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]

    description = "https"
  }]
  
}

variable "instance_count" {
  description = "No of instances to create"
  type = number
  default = 2
  
}