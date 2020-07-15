module "dns" {
  source = "../cloudflare/dns"
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id = var.cloudflare_zone_id
  jitsi_domain = var.subdomain
  jitsi_public_ip = var.jitsi_public_ip
  turn_domain = "turn.${var.subdomain}"
  turn_public_ip = var.turn_public_ip
  has_dedicated_turnserver = var.has_dedicated_turnserver
}

module "secrets" {
  source = "../secrets"
}

module "installer" {
  source = "./install"
  jitsi_public_ip = var.jitsi_public_ip
  turn_public_ip = var.turn_public_ip
  has_dedicated_turnserver = var.has_dedicated_turnserver
  ssh_key_path = var.ssh_key_path
}

module "turnprovisioner" {
  count = var.has_dedicated_turnserver ? 1 : 0
  source = "../turn"
  depends_on = [module.installer, module.dns.turn_fqdn]
  domain_name = module.dns.turn_fqdn
  realm = module.dns.jitsi_fqdn
  host_ip = var.turn_public_ip
  turn_secret = module.secrets.turn_secret
  ssh_key_path = var.ssh_key_path
  email = var.email_address
}

module "jitsi" {
  source = "../"
  depends_on = [module.installer, module.dns.jitsi_fqdn]
  domain_name = module.dns.jitsi_fqdn
  admin_username = var.admin_username
  admin_password = var.admin_password
  email_address = var.email_address
  host_ip = var.jitsi_public_ip
  ssh_key_path = var.ssh_key_path
  enable_recording_streaming = var.enable_recording_streaming
  has_dedicated_turnserver = var.has_dedicated_turnserver
  turn_secret = module.secrets.turn_secret
  turndomain = var.has_dedicated_turnserver ? module.dns.turn_fqdn : ""
  is_secure_domain = var.is_secure_domain
  interface_background_color = var.interface_background_color
  interface_remote_display_name = var.interface_remote_display_name
  interface_watermark_link = var.interface_watermark_link
  interface_app_name = var.interface_app_name
  interface_provider_name = var.interface_provider_name
  interface_watermark_image_url = var.interface_watermark_image_url
}
