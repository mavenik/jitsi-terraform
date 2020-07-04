output "nameservers" {
  description = "Nameservers for hosted zone"
  value = aws_route53_zone.jitsi.name_servers
}
