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
