variable "subdomain" {
  description = "(Optional) Subdomain at which a Jitsi server will be hosted"
  type = string
}

variable "cloudflare_api_token" {
  description = "API Token for your CloudFlare account"
  type = string
  default = ""
}

variable "cloudflare_zone_id" {
  description = "Zone ID of the top-level domain"
  type        = string
}

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

variable "email_address" {
  description = "Email to be used for SSL certificate generation using Let's Encrypt"
  type        = string
}

variable "admin_username" {
  description = "Moderator username. Only this user will be allowed to start meets."
  type        = string
}

variable "admin_password" {
  description = "Password for moderator user. Only this user will be allowed to start meets."
  type        = string
}

variable "enable_recording_streaming" {
  description = "Enables recording and streaming capability on Jitsi Meet"
  type        = bool
  default     = false
}

variable "has_dedicated_turnserver" {
  description = "Whether this setup has a dedicated TURN server or not"
  type = bool
  default = false
}

variable "is_secure_domain" {
  description = "Enable/disable secure domain"
  type = bool
  default = true
}

variable "interface_background_color" {
  description = "(Optional) Background color of the interface"
  type = string
  default = "#474747"
}

variable "interface_remote_display_name" {
  description = "(Optional) Remote display name during call"
  type = string
  default = "Fellow Jitser"
}

variable "interface_watermark_link" {
  description = "(Optional) Link on watermark image"
  type = string
  default = "https://jitsi.org"
}

variable "interface_app_name" {
  description = "(Optional) App Name to be displayed"
  type = string
  default = "Jitsi Meet"
}

variable "interface_provider_name" {
  description = "(Optional) Provider name to be displayed on the interface"
  type = string
  default = "Jitsi"
}

variable "interface_watermark_image_url" {
  description = "(Optional) Watermark logo URL"
  type = string
  default = "https://meet.jit.si/images/watermark.png"
}
