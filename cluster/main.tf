terraform {
  backend "s3" {
    bucket         = "jitsi-terraform-state-provision-only-cluster"
    key            = "provision-only-cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "jitsi-terraform-provision-only-cluster-locks"
    encrypt        = true
  }
}
provider "cloudflare" {
  version = "~> 2.0"
  api_token = var.cloudflare_api_token
}
module "dns" {
  for_each = var.servers
  source = "../cloudflare/dns"
  providers = {
    cloudflare = cloudflare
  }
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id = var.cloudflare_zone_id
  jitsi_domain = "${var.subdomain}${each.key}"
  jitsi_public_ip = each.value.public_ip
  turn_domain = "${var.turndomain}${each.key}"
  turn_public_ip = each.value.public_ip
  has_additional_turn = var.has_additional_turn
  has_dedicated_turnserver = var.has_dedicated_turnserver
}

module "secrets" {
  source = "../secrets"
}

module "installer" {
  for_each = var.servers
  source = "./install"
  jitsi_public_ip = each.value.public_ip
  turn_public_ip = each.value.public_ip
  has_dedicated_turnserver = var.has_dedicated_turnserver
  has_additional_turn = var.has_additional_turn
  ssh_key_path = var.ssh_key_path
}

module "jitsi" {
  for_each = var.servers
  source = "../"
  depends_on = [module.installer, module.dns]
  domain_name = lookup(module.dns, each.key).jitsi_fqdn
  admin_username = var.admin_username
  admin_password = var.admin_password
  email_address = var.email_address
  host_ip = each.value.public_ip
  private_ip = each.value.private_ip
  ssh_key_path = var.ssh_key_path
  enable_recording_streaming = var.enable_recording_streaming
  has_dedicated_turnserver = var.has_dedicated_turnserver
  turn_secret = module.secrets.turn_secret
  turndomain = lookup(module.dns, each.key).turn_fqdn
  is_secure_domain = var.is_secure_domain
  interface_background_color = var.interface_background_color
  interface_remote_display_name = var.interface_remote_display_name
  interface_watermark_link = var.interface_watermark_link
  interface_app_name = var.interface_app_name
  interface_provider_name = var.interface_provider_name
  interface_watermark_image_url = var.interface_watermark_image_url
  interface_show_watermark = var.interface_show_watermark
  interface_allow_shared_video = var.interface_allow_shared_video
  interface_disable_mobile_app = var.interface_disable_mobile_app
}
