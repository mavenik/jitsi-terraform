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
  depends_on = [module.subdomain.value, aws_instance.jitsi]
  subdomain = module.subdomain.value
  parent_subdomain = var.parent_subdomain
  public_ip = aws_instance.jitsi.public_ip
}

module "security" {
  source = "./security"
  enable_ssh_access = var.enable_ssh_access
  enable_recording_streaming = var.enable_recording_streaming
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

