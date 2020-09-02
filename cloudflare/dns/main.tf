resource "cloudflare_record" "jitsi" {
  zone_id = var.cloudflare_zone_id
  name    = var.jitsi_domain
  value   = var.jitsi_public_ip
  type    = "A"
}

resource "cloudflare_record" "turn" {
  zone_id = var.cloudflare_zone_id
  name = var.turn_domain
  value = var.turn_public_ip
  type = "A"
}

resource "cloudflare_record" "additional_turn" {
  count = var.has_additional_turn ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name = var.additional_turn_domain
  value = var.additional_turn_public_ip
  type = "A"
}

