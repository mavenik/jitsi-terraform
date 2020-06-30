locals {
  subdomain = length(var.subdomain) == 0 ? random_id.server_id.hex : var.subdomain
}

resource "random_id" "server_id" {
  byte_length = 4
}
