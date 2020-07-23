output "fqdn" {
  value = module.dns.fqdn
}
output "public_ip" {
  value = aws_instance.jitsi.public_ip
}
output "turn_public_ip" {
  value = join("", module.turnserver.*.public_ip)
}
