variable "region" {
  type = string
}

variable "domain" {
  type = string
}
variable "app_dns_zone" {
  type = string
}

variable "workstation_ip" {
  type = string
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
}

variable "availability_zones" {
  type = list(any)
}

variable "keypair_path" {
  type = string
}
variable "bastion_instance_type" {
  type = string
}
variable "bastion_ami" {
  type = string
}
variable "app_instance_type" {
  type = string
}
variable "app_ami" {
  type = string
}
variable "db_instance_type" {
  type = string
}
variable "db_ami" {
  type = string
}
variable "profile" {
  type = string
}