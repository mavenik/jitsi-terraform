data "aws_security_groups" "jitsi" {
  filter {
       name = "group-name"
       values = concat(
                [
                  "allow_connections_jitsi_meet",
                  "allow_connections_jitsi_meet-ssh"
                ],
                (var.enable_recording_streaming ? ["allow_connections_jitsi_meet-recording-streaming"] : [])
                )
  }
}

data "aws_security_groups" "turn" {
  filter {
    name = "group-name"
    values = [
              "allow_connections_jitsi_meet-ssh",
              "allow_connections_jitsi_turn"
             ]
  }
}
