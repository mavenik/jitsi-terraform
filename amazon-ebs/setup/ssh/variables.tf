variable "ssh_public_key" {
  description = "SSH Public key for deployment"
  type = string
}

variable "ssh_key_name" {
  description = "SSH Key Name"
  type = string
  default = "jitsi"
}
