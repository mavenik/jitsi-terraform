output "fqdn" {
  description = "FQDN for Route53 record"
  value = aws_route53_record.jitsi.fqdn
}

output "turnfqdn" {
  description = "FQDN of TURN Server"
  value = join("", aws_route53_record.turn.*.fqdn)
}
