variable "jitsi_public_ip" {
  description = "Public IP of Jitsi server"
  type        = string
}

variable "turn_public_ip" {
  description = "(Optional) Public IP of TURN Server. Required if turn_domain is set."
  type = string
  default = ""
}

variable "ssh_key_path" {
  description = "Path to SSH private key"
  type = string
}

variable "has_dedicated_turnserver" {
  description = "Whether this setup has a dedicated TURN server or not"
  type = bool
  default = false
}
