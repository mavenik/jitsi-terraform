provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

locals {
  subdomain = length(var.subdomain) == 0 ? random_id.server_id.hex : var.subdomain
}

data "template_file" "stream_record" {
  template = file("./templates/jibri/stream_record.tpl")
  vars = {
    recorded_stream_dir = var.recorded_stream_dir
  }
}

data "template_file" "facebook_stream" {
  template = file("./templates/jibri/facebook_stream.tpl")
  vars = {
    facebook_stream_key = var.facebook_stream_key
  }
}

data "template_file" "periscope_stream" {
  template = file("./templates/jibri/periscope_stream.tpl")
  vars = {
    periscope_server_url = var.periscope_server_url
    periscope_stream_key = var.periscope_stream_key
  }
}

data "template_file" "twitch_stream" {
  template = file("./templates/jibri/twitch_stream.tpl")
  vars = {
    twitch_ingest_endpoint = var.twitch_ingest_endpoint
    twitch_stream_key      = var.twitch_stream_key
  }
}

data "template_file" "youtube_stream" {
  template = file("./templates/jibri/youtube_stream.tpl")
  vars = {
    youtube_stream_key = var.youtube_stream_key
  }
}

data "template_file" "generic_streams" {
  template = file("./templates/jibri/generic_stream.tpl")
  count    = length(var.rtmp_stream_urls)
  vars = {
    stream_url = var.rtmp_stream_urls[count.index]
  }
}

data "template_file" "install_jibri" {
  template = "${file("install_jibri.tpl")}"
  vars = {
    jibri_auth_password     = random_id.jibriauthpass.hex
    jibri_recorder_password = random_id.jibrirecorderpass.hex
    recorded_stream_dir     = var.recorded_stream_dir
    record_stream           = var.record_all_streaming ? data.template_file.stream_record.rendered : "    record off;"
    facebook_stream         = (length(var.facebook_stream_key) != 0) ? data.template_file.facebook_stream.rendered : "# Facebook stream was not configured"
    periscope_stream        = (length(var.periscope_stream_key) != 0) ? data.template_file.periscope_stream.rendered : "# Periscope stream was not configured"
    twitch_stream           = (length(var.twitch_stream_key) != 0) ? data.template_file.twitch_stream.rendered : "# Twitch stream was not configured"
    youtube_stream          = (length(var.youtube_stream_key) != 0) ? data.template_file.youtube_stream.rendered : "# YouTube stream was not configured"
    generic_streams         = (length(var.rtmp_stream_urls) != 0) ? join("\n    ", data.template_file.generic_streams.*.rendered) : "# No generic stream URLs were configured"
  }
}

data "template_file" "install_script" {
  template = "${file("install_jitsi.tpl")}"
  vars = {
    email_address             = "${var.email_address}"
    admin_username            = "${var.admin_username}"
    admin_password            = "${var.admin_password}"
    domain_name               = "${local.subdomain}.${var.parent_subdomain}"
    jibri_installation_script = var.enable_recording_streaming ? data.template_file.install_jibri.rendered : "echo \"Jibri installation is disabled\" >> /debug.txt"
    reboot_script             = var.enable_recording_streaming ? "echo \"Rebooting...\" >> /debug.txt\nreboot" : "echo \".\" >> /debug.txt"
  }
}

data "aws_route53_zone" "parent_subdomain" {
  name = var.parent_subdomain
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  #/ubuntu-disco-19.04-amd64-server-
  #/ubuntu-bionic-18.04-amd64-server-
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "jitsi" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_connections_jitsi-meet.id]
  key_name               = var.enable_ssh_access ? var.ssh_key_name : null
  user_data              = data.template_file.install_script.rendered
  tags = {
    Name = "jitsi-meet-server-${local.subdomain}"
  }
}

resource "random_id" "jibriauthpass" {
  byte_length = 8
}
resource "random_id" "jibrirecorderpass" {
  byte_length = 8
}
resource "random_id" "server_id" {
  byte_length = 4
}

resource "aws_route53_record" "jitsi" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${local.subdomain}.${var.parent_subdomain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jitsi.public_ip]
}

resource "aws_security_group" "allow_connections_jitsi-meet" {
  name        = "allow_connections_jitsi-meet"
  description = "Allow traffic on UDP 10000 (JVB) TCP 443 (HTTPS) UDP 53 (DNS)"

  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

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
    protocol    = "6"
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

  dynamic "egress" {
    for_each = var.enable_recording_streaming ? [1] : []
    content {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.enable_recording_streaming ? [1] : []
    content {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  tags = {
    Name = "allow_connections_jitsi-meet"
  }
}
