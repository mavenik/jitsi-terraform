output "fqdn" {
  value = module.dns.fqdn
}
output "public_ip" {
  value = aws_instance.jitsi.public_ip
}
