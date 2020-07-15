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
  count = length(var.turn_domain) > 0 && length(var.turn_public_ip) > 0 ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name = var.turn_domain
  value = var.turn_public_ip
  type = "A"
}
