output "vpc_security_group_ids" {
  description = "Security group IDs"
  value = data.aws_security_groups.jitsi.ids
}

output "vpc_turn_security_group_ids" {
  description = "Security group ID for TURN Server"
  value = data.aws_security_groups.turn.ids
}
