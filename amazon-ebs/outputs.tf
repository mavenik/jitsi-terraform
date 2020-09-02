output "fqdn" {
  value = module.dns.fqdn
}
output "public_ip" {
  value = aws_instance.jitsi.public_ip
}
output "turn_public_ip" {
  value = var.has_dedicated_turnserver ? join("", module.turnserver.*.public_ip) : aws_instance.jitsi.public_ip
}
output "turn_private_ip" {
 value = var.has_dedicated_turnserver ? join("", module.turnserver.*.private_ip) : aws_instance.jitsi.private_ip
}
output "turnfqdn" {
  value = module.dns.turnfqdn
}
