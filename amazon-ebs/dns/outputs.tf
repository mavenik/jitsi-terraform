output "fqdn" {
  description = "FQDN for Route53 record"
  value = aws_route53_record.jitsi.fqdn
}
