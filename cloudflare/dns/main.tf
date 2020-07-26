provider "cloudflare" {
  version = "~> 2.0"
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "jitsi" {
  zone_id = var.cloudflare_zone_id
  name    = var.jitsi_domain
  value   = var.jitsi_public_ip
  type    = "A"
}

resource "cloudflare_record" "turn" {
  count = var.has_dedicated_turnserver ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name = var.turn_domain
  value = var.turn_public_ip
  type = "A"
}

locals {
  # gh_ip = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"] 
  gh_ip = [] 
}
resource "cloudflare_record" "root" {
  count = length(local.gh_ip)
  zone_id = var.cloudflare_zone_id
  name = "@"
  value = local.gh_ip[count.index]
  type = "A"
}
