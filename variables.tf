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
  description = "(Optional) Enable/disable streaming and recording capability over RTMP"
  type = bool
  default = false
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

variable "domain_name" {
  description = "Fully Qualified Domain Name for this server"
  type        = string
}

variable "ssh_key_path" {
  description = "SSH Private Key Path"
  type = string
}

variable "host_ip" {
  description = "Host IP of the server"
  type = string
}
