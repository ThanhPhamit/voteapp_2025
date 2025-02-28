variable "availability_zones" {
  type = list(any)
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}