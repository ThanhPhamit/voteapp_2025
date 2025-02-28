variable "domain_name" {}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
variable "alb_dns_name" {}

variable "virginia_certificate_arn" {}

variable "hosted_zone_id" {}

variable "alb_sg_id" {
  
}