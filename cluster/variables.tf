variable "subdomain" {
  description = "Base subdomain at which a Jitsi servers will be hosted"
  type = string
}

variable "turndomain" {
  description = "Base TURN domain at which TURN servers will be available"
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

variable "servers" {
  type = map
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
  default = ""
}

variable "admin_password" {
  description = "Password for moderator user. Only this user will be allowed to start meets."
  type        = string
  default = ""
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

variable "has_additional_turn" {
  type = bool
  default = false
}

variable "additional_turn_domain" {
  description = "Extra turn server domain"
  type = string
  default = ""
}

variable "additional_turn_public_ip" {
  description = "Extra TURN server IP"
  type = string
  default = ""
}

variable "additional_turn_private_ip" {
  description = "Extra TURN server private IP"
  type = string
  default = ""
}

variable "is_secure_domain" {
  description = "Enable/disable secure domain"
  type = bool
  default = false
}

variable "interface_background_color" {
  description = "(Optional) Background color of the interface"
  type = string
  default = "#474747"
}

variable "interface_remote_display_name" {
  description = "(Optional) Remote display name during call"
  type = string
  default = "Fellow Jitster"
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
  default = "images/watermark.png"
}

variable "interface_show_watermark" {
  description = "(Optional) Enables/disables watermark"
  type = bool
  default = true
}

variable "interface_allow_shared_video" {
  description = "(Optional) Enables/Disables share YouTube Video feature"
  type = bool
  default = true
}

variable "interface_disable_mobile_app" {
  description = "(Optional) Enables/disables mobile app download screen"
  type = bool
  default = false
}
