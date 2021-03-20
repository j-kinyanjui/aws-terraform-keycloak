variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "TerraformInstance"
}

variable "sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
  ]
}

variable "security_groups_name" {
  type    = string
  default = "tf-security_group"
}