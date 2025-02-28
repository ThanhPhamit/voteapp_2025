variable "vpc_id" {
  type = string
}

variable "workstation_ip" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}