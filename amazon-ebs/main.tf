provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "subdomain" {
  source = "../subdomain"
  subdomain = var.subdomain
}

module "dns" {
  source = "./dns"
  depends_on = [module.subdomain.value, aws_instance.jitsi, module.turnserver]
  subdomain = module.subdomain.value
  parent_subdomain = var.parent_subdomain
  public_ip = aws_instance.jitsi.public_ip
  
  has_dedicated_turnserver = var.has_dedicated_turnserver
  turndomain = var.has_dedicated_turnserver ? "turn.${module.subdomain.value}" : ""
  turnserver_ip = var.has_dedicated_turnserver ? join("", module.turnserver.*.public_ip) : ""
}

module "security" {
  source = "./security"
  enable_ssh_access = var.enable_ssh_access
  enable_recording_streaming = var.enable_recording_streaming
}

module "secrets" {
  source = "../secrets"
}

module "turnserver" {
  count = var.has_dedicated_turnserver ? 1 : 0
  depends_on = [module.subdomain.value]
  source = "./turn"
  ssh_key_name = var.ssh_key_name
  instance_type = var.turn_instance_type
  security_group_ids = module.security.vpc_turn_security_group_ids
  domain_name = "turn.${module.subdomain.value}"
}

module "turnprovisioner" {
  count = var.has_dedicated_turnserver ? 1 : 0
  source = "../turn"
  depends_on = [module.dns.turnfqdn]
  domain_name = module.dns.turnfqdn
  realm = module.dns.fqdn
  host_ip = join("", module.turnserver.*.public_ip)
  turn_secret = module.secrets.turn_secret
  ssh_key_path = var.ssh_key_path
  email = var.email_address
}

module "jitsi" {
  source = "../"
  depends_on = [module.dns.fqdn]
  domain_name = module.dns.fqdn
  admin_username = var.admin_username
  admin_password = var.admin_password
  email_address = var.email_address
  host_ip = aws_instance.jitsi.public_ip
  ssh_key_path = var.ssh_key_path
  enable_recording_streaming = var.enable_recording_streaming
  has_dedicated_turnserver = var.has_dedicated_turnserver
  turn_secret = module.secrets.turn_secret
  turndomain = var.has_dedicated_turnserver ? module.dns.turnfqdn : ""
  is_secure_domain = var.is_secure_domain
  interface_background_color = var.interface_background_color
  interface_remote_display_name = var.interface_remote_display_name
  interface_watermark_link = var.interface_watermark_link
  interface_app_name = var.interface_app_name
  interface_provider_name = var.interface_provider_name
  interface_watermark_image_url = var.interface_watermark_image_url
}

data "aws_ami" "packer_jitsi" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-jitsi-ami-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["610596688011"]
}

resource "aws_instance" "jitsi" {
  ami                    = data.aws_ami.packer_jitsi.id
  instance_type          = var.instance_type
  vpc_security_group_ids = module.security.vpc_security_group_ids
  key_name               = var.enable_ssh_access ? var.ssh_key_name : null
  tags = {
    Name = "jitsi-meet-server-${module.subdomain.value}"
  }
  
}

