output "nameservers" {
  description = "Nameservers for hosted zone"
  value = module.dns.nameservers
}
