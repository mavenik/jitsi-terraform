variable "domain_name" {
  description = "Domain Name of TURN Server"
  type = string
}

variable "turn_domain" {
  description = "Domain Name of TURN Server"
  type = string
}

variable "turn_secret" {
  description = "Secret password for TURN server"
  type = string
}

variable "host_ip" {
  description = "IP Address of TURN Host"
  type = string
}

variable "private_ip" {
  description = "Private IP address of TURN Host"
  type = string
}

variable "ssh_key_path" {
  description = "Path to SSH private key"
  type = string
}

variable "realm" {
  description = "Realm for Coturn"
  type = string
}

variable "email" {
  description = "Email for Let's Encrypt"
  type = string
}
