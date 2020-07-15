variable "parent_subdomain" {
  description = "Parent (sub)domain for Jitsi server"
  type = string
}

variable "subdomain" {
  description = "Subdomain on which Jitsi server will be hosted under the parent subdomain"
  type = string
}

variable "public_ip" {
  description = "Host IP of Jitsi server"
  type = string
}

variable "has_dedicated_turnserver" {
  description = "Whether this Jitsi setup has a dedicated TURN server or not"
  type = bool
  default = false
}

variable "turndomain" {
  description = "(Optional) Domain name of dedicated TURN server"
  type = string
  default = ""
}

variable "turnserver_ip" {
  description = "(Optional) IP Address of dedicated TURN Server"
  type = string
  default = ""
}
