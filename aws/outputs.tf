output "server_hostname" {
  value = aws_route53_record.jitsi.name
}

output "server_url" {
  value = "https://${aws_route53_record.jitsi.name}"
}
