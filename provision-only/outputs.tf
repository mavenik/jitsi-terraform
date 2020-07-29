output "server" {
  description = "Server hostname"
  value = module.dns.jitsi_fqdn
}

output "turnserver" {
  description = "TURN Server hostname"
  value = module.dns.turn_fqdn
}
