output "turn_secret" {
  description = "TURN secret"
  value = random_password.turn_secret.result
}
