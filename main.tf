terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_security_group" "tf_security_group" {
  vpc_id = aws_vpc.tf_vpc.id
  name   = var.security_groups_name

  tags = {
    Name = "tf-security-group"
  }
}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.sg_ingress_rules)

  type              = "ingress"
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  protocol          = var.sg_ingress_rules[count.index].protocol
  cidr_blocks       = [var.sg_ingress_rules[count.index].cidr_block]
  description       = var.sg_ingress_rules[count.index].description
  security_group_id = aws_security_group.tf_security_group.id
}

resource "random_integer" "availability_zone" {
  min = 0
  max = length(var.public_subnets)
}

resource "aws_subnet" "tf_subnet" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = var.public_subnets[random_integer.availability_zone.result].cidr_block
  availability_zone       = var.public_subnets[random_integer.availability_zone.result].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.public_subnets[random_integer.availability_zone.result].availability_zone}-public-subnet"
  }
}

resource "aws_network_interface" "tf_net_int" {
  subnet_id       = element(aws_subnet.tf_subnet.*.id, random_integer.availability_zone.result)
  security_groups = [aws_security_group.tf_security_group.id]

  tags = {
    Name = "tf-network-interface"
  }
}

resource "aws_vpc_dhcp_options" "tf_dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = "foo-name"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.tf_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.tf_dhcp_options.id
}

resource "aws_instance" "tf_instance" {
  ami           = "ami-0de9f803fcac87f46"
  instance_type = "t2.micro"
  key_name      = "atlassian_keycloak"

  network_interface {
    network_interface_id = element(aws_network_interface.tf_net_int.*.id, random_integer.availability_zone.result)
    device_index         = 0
  }

  tags = {
    Name = var.instance_name
  }
}
