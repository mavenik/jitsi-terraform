resource "aws_route53_zone" "jitsi" {
  name = var.parent_subdomain
}
