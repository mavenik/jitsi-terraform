output "public_ip" {
  description = "Public IP of TURN server"
  value = aws_instance.turn.public_ip
}
