data "aws_route53_zone" "parent_subdomain" {
  name = var.parent_subdomain
}

resource "aws_route53_record" "jitsi" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${var.subdomain}.${var.parent_subdomain}"
  type    = "A"
  ttl     = "300"
  records = [var.public_ip]
}

resource "aws_route53_record" "turn" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${var.turndomain}.${var.parent_subdomain}"
  type    = "A"
  ttl     = "300"
  records = [var.turnserver_ip]
}
