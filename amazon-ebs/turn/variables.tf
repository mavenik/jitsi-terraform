variable "instance_type" {
  description = "Instance type for TURN server"
  type = string
  default = "t3.micro"
}

variable "ssh_key_name" {
  description = "Name of SSH Key Pair"
  type = string
}

variable "security_group_ids" {
  description = "Security group IDs for TURN server"
  type = list
}

variable "domain_name" {
  description = "Domain Name for TURN server"
  type = string
}
