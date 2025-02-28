terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
      configuration_aliases = [
        aws,
        aws.virginia
      ]
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.5"
    }
  }
}


# resource "aws_acm_certificate" "this" {
#   domain_name       = var.domain
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${var.domain}"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_acm_certificate" "virginia" {
  domain_name       = var.domain
  validation_method = "DNS"
  provider          = aws.virginia

  subject_alternative_names = [
    "*.${var.domain}"
  ]

  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}

data "aws_route53_zone" "this" {
  name         = var.app_dns_zone
  private_zone = false
}

resource "aws_route53_record" "this" {
  depends_on = [aws_acm_certificate.virginia]

  for_each = {
    for dvo in aws_acm_certificate.virginia.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.this.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  allow_overwrite = true
}

# 初回実行時は以下コメントアウトが必要かも　要検証
# resource "aws_acm_certificate_validation" "this" {
#   depends_on              = [aws_route53_record.this]
#   certificate_arn         = aws_acm_certificate.this.arn
#   validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
#   # provider = aws.virginia
# }

resource "aws_acm_certificate_validation" "virginia" {
  depends_on              = [aws_route53_record.this]
  certificate_arn         = aws_acm_certificate.virginia.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
  provider                = aws.virginia
}
