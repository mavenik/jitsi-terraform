variable "aws_region" {
  description = "Amazon AWS Region for this setup"
  type = string
  default = "ap-south-1"
}

variable "parent_subdomain" {
  description = "Parent subdomain under which Jitsi servers will be hosted"
  type = string
}

variable "ssh_public_key" {
  description = "SSH Public key for deployment"
  type = string
}

variable "ssh_key_name" {
  description = "SSH Key Name"
  type = string
  default = "jitsi"
}
