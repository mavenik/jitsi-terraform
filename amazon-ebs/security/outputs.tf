output "vpc_security_group_ids" {
  description = "Security group IDs"
  value = data.aws_security_groups.jitsi.ids
}
