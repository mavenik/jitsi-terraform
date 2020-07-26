output "jitsi_fqdn" {
  description = "FQDN for Jitsi server"
  value = cloudflare_record.jitsi.hostname 
}

output "turn_fqdn" {
  description = "FQDN for TURN server"
  value = join("", cloudflare_record.turn.*.hostname)
}

output "root_domain" {
  description = "FQDN for Root domain"
  value = join(", ", cloudflare_record.root.*.hostname)
}
