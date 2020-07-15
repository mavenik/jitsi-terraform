locals {
  ansible_vars = jsonencode({
  "domain_name" = var.domain_name
  "admin_username" = var.admin_username
  "admin_password" = var.admin_password
  "jicofo_secret" = random_password.jicofo_secret.result
  "jicofo_focus_password" = random_password.jicofo_focus_password.result
  "jvb_secret" = random_password.jvb_secret.result
  "jvb_nickname" = random_id.jvb_nickname.hex
  "email" = var.email_address
  "public_ip" = var.host_ip
  "has_dedicated_turnserver" = var.has_dedicated_turnserver
  "turn_secret" = var.turn_secret
  "turndomain" = var.turndomain
  "is_secure_domain" = var.is_secure_domain
  "interface_background_color" = var.interface_background_color
  "interface_remote_display_name" = var.interface_remote_display_name
  "interface_watermark_link" = var.interface_watermark_link
  "interface_app_name" = var.interface_app_name
  "interface_provider_name" = var.interface_provider_name
  "interface_watermark_image_url" = var.interface_watermark_image_url
  })
}

resource "random_password" "jicofo_secret" {
  length = 8
  special = false
}

resource "random_password" "jicofo_focus_password" {
  length = 8
  special = false
}

resource "random_password" "jvb_secret" {
  length = 8
  special = false
}

resource "random_id" "jvb_nickname"{
   byte_length = 8
}

resource "null_resource" "ansible" {
  triggers = {
     instance_id = var.host_ip
  }
  
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }

    source = "../playbooks/jitsi"
    destination = "/tmp"
  }
  
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }

    content = local.ansible_vars
    destination = "/tmp/jitsi/host_vars.json"
  }

  provisioner "remote-exec" {
    inline = ["ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python' --extra-vars '@/tmp/jitsi/host_vars.json' /tmp/jitsi/jitsi.yml"]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = ["rm -rf /tmp/jitsi"]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }
  }

}

resource "random_id" "jibriauthpass" {
  byte_length = 8
}
resource "random_id" "jibrirecorderpass" {
  byte_length = 8
}

