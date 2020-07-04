provider "aws" {
  region = var.aws_region
}

module "security" {
  source = "./security"
}

module "dns" {
  source = "./dns"
  parent_subdomain = var.parent_subdomain
}

module "ssh" {
  source = "./ssh"
  ssh_key_name = var.ssh_key_name
  ssh_public_key = var.ssh_public_key
}
