provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "subdomain" {
  source = "../subdomain"
  subdomain = var.subdomain
}
module "jitsi" {
  source = "../"
  depends_on = [aws_route53_record.jitsi, module.subdomain.value]
  domain_name = "${module.subdomain.value}.${var.parent_subdomain}"
  admin_username = var.admin_username
  admin_password = var.admin_password
  email_address = var.email_address
  host_ip = aws_instance.jitsi.public_ip
  ssh_key_path = var.ssh_key_path
}

data "aws_ami" "packer_jitsi" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-jitsi-ami-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["610596688011"]
}

resource "aws_instance" "jitsi" {
  ami                    = data.aws_ami.packer_jitsi.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_connections_jitsi-meet.id]
  key_name               = var.enable_ssh_access ? var.ssh_key_name : null
  tags = {
    Name = "jitsi-meet-server-${module.subdomain.value}"
  }
  
}

data "aws_route53_zone" "parent_subdomain" {
  name = var.parent_subdomain
}

resource "aws_route53_record" "jitsi" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${module.subdomain.value}.${var.parent_subdomain}"
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
