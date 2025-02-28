terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

#creating Cloudfront distribution :
resource "aws_cloudfront_distribution" "voteapp_dist" {
  enabled             = true
  aliases             = [var.domain_name]
  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.alb_dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.alb_dns_name
    viewer_protocol_policy = "redirect-to-https"

    # Deprecated in favor of cache_policy_id
    # forwarded_values {
    #   headers      = []
    #   query_string = true
    #   cookies {
    #     forward = "all"
    #   }
    # 

    cache_policy_id = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
  viewer_certificate {
    acm_certificate_arn      = var.virginia_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "voteapp" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.voteapp_dist.domain_name
    zone_id                = aws_cloudfront_distribution.voteapp_dist.hosted_zone_id
    evaluate_target_health = true
  }
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  filter {
    name   = "owner-id"
    values = ["AWS"]
  }

  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
}
resource "aws_security_group_rule" "alb_ingress_cloudfront" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = var.alb_sg_id
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]

  depends_on = [
    aws_cloudfront_distribution.voteapp_dist
  ]
}