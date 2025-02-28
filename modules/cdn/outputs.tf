output "cloudfront_domain_name" {
  value = tolist(aws_cloudfront_distribution.voteapp_dist.aliases)[0]
}