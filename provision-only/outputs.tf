output "server" {
  description = "Server hostname"
  value = module.dns.jitsi_fqdn
}

output "root" {
  description = "Root domain"
  value = module.dns.root_domain
}
