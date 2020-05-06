provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "template_file" "install_script" {
  template = "${file("install_jitsi.tpl")}"
  vars = {
    email_address  = "${var.email_address}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    domain_name    = "${random_id.server_id.hex}.${var.parent_subdomain}"
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
  #  key_name = var.ssh_key_name
  user_data = data.template_file.install_script.rendered
  tags = {
    Name = "jitsi-meet-server-${random_id.server_id.hex}"
  }
}

resource "random_id" "server_id" {
  byte_length = 4
}

resource "aws_route53_record" "jitsi" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${random_id.server_id.hex}.${var.parent_subdomain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jitsi.public_ip]
}

resource "aws_security_group" "allow_connections_jitsi-meet" {
  name        = "allow_connections_jitsi-meet"
  description = "Allow traffic on UDP 10000 (JVB) TCP 443 (HTTPS) UDP 53 (DNS)"

  #  ingress {
  #    from_port   = 22
  #    to_port     = 22
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

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
  tags = {
    Name = "allow_connections_jitsi-meet"
  }
}
