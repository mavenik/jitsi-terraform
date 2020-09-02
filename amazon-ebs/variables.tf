variable "aws_profile" {
  description = "AWS Credentials profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS Region where this server will be hosted"
  type        = string
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

variable "enable_ssh_access" {
  description = "Whether to allow SSH access or not. Requires SSH Key to be imported to AWS Console."
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "(Optional) SSH Key Pair name as set up in AWS. This is for debugging with SSH access."
  type        = string
  default = "jitsi"
}

variable "instance_type" {
  description = "AWS Instance type for this Jitsi instance"
  type        = string
}

variable "parent_subdomain" {
  description = "Parent domain/subdomain. Server will be hosted at https://<UUIDv4>.parent_subdomain"
  type        = string
}

variable "enable_recording_streaming" {
  description = "Enables recording and streaming capability on Jitsi Meet"
  type        = bool
  default     = false
}

variable "record_all_streaming" {
  description = "(Optional) Records every stream if set to true"
  type        = bool
  default     = false
}

variable "recorded_stream_dir" {
  description = "(Optional) Base directory where recorded streams will be available."
  type        = string
  default     = "/var/www/html/recordings"
}

variable "facebook_stream_key" {
  description = "(Optional) Stream Key for Facebook"
  type        = string
  default     = ""
}

variable "periscope_server_url" {
  description = "(Optional) Periscope streaming server base URL"
  type        = string
  default     = "rtmp://in.pscp.tv:80/x"
}

variable "periscope_stream_key" {
  description = "(Optional) Streaming key for Periscope"
  type        = string
  default     = ""
}

variable "youtube_stream_key" {
  description = "(Optional) YouTube stream key"
  type        = string
  default     = ""
}

variable "twitch_ingest_endpoint" {
  description = "(Optional) Ingest endpoint for Twitch. E.g. rtmp://live-mrs.twitch.tv/app"
  default     = "rtmp://live-sin.twitch.tv/app"
}

variable "twitch_stream_key" {
  description = "(Optional) Streaming key for Twitch"
  default     = ""
}

variable "rtmp_stream_urls" {
  description = "(Optional) A list of generic RTMP URLs for streaming"
  type        = list
  default     = []
}

variable "subdomain" {
  description = "(Optional) Subdomain under a parent domain to host this instance"
  type        = string
  default     = ""
}

variable "ssh_key_path" {
  description = "SSH Private Key Path"
  type = string
}

variable "has_dedicated_turnserver" {
  description = "Whether this setup has a dedicated TURN server or not"
  type = bool
  default = false
}

variable "turndomain" {
  description = "Domain name for TURN server"
  type = string
  default = ""
}

variable "turn_instance_type" {
  description = "TURN instance type"
  type = string
  default = "t3.micro"
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
