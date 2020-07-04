variable "enable_ssh_access" {
  description = "(Optional) Enable/disable SSH access over port 22"
  type = bool
  default = true
}

variable "enable_recording_streaming" {
  description = "(Optional) Enable/disable streaming and recording capability over RTMP"
  type = bool
  default = false
}
