variable "cloudflare_api_token" {
  description = "API Token for your CloudFlare account"
  type = string
  default = ""
}

variable "cloudflare_zone_id" {
  description = "Zone ID of the top-level domain"
  type        = string
}

variable "jitsi_domain" {
  description = "Subdomain on which Jitsi server will be hosted"
  type        = string
}

variable "jitsi_public_ip" {
  description = "Public IP of Jitsi server"
  type        = string
}

variable "turn_domain" {
  description = "(Optional) Subdomain for TURN server"
  type = string
  default = ""
}

variable "turn_public_ip" {
  description = "(Optional) Public IP of TURN Server. Required if turn_domain is set."
  type = string
  default = ""
}

variable "has_dedicated_turnserver" {
  description = "(Optional) Whether this Jitsi server has a dedicated TURN server or not"
  type = bool
  default = false
}
