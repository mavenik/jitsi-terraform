output "fqdn" {
  value = aws_route53_record.jitsi.name
}
output "public_ip" {
  value = aws_instance.jitsi.public_ip
}
