resource "aws_security_group" "allow_connections_jitsi-meet" {
  name        = "allow_connections_jitsi_meet"
  description = "Allow traffic on UDP 10000 (JVB) TCP 80/443 (HTTP/HTTPS) UDP 53 (DNS) UDP 4446 (STUN)"

  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4446
    to_port     = 4446
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 4446
    to_port     = 4446
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jitsi"
  }
}

resource "aws_security_group" "allow_connections_jitsi-meet-ssh" {
  name        = "allow_connections_jitsi_meet-ssh"
  description = "Allows SSH access over port 22"

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jitsi"
  }
}

resource "aws_security_group" "allow_connections_jitsi-meet-recording-streaming" {
  name        = "allow_connections_jitsi_meet-recording-streaming"
  description = "Allows RTMP traffic on ports 1935 and 1936"

  egress {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jitsi"
  }
}

resource "aws_security_group" "allow_connections_jitsi-turn" {
  name        = "allow_connections_jitsi_turn"
  description = "Allow traffic on UDP 4446 (TURN/STUN UDP) TCP 443 (TURNS) UDP 53 for DNS and to UDP 10000 for outbound JVB"

  egress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4446
    to_port     = 4446
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 4446
    to_port     = 4446
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jitsi"
  }
}
