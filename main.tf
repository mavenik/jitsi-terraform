locals {
  ansible_vars = jsonencode({
  "domain_name" = var.domain_name
  "admin_username" = var.admin_username
  "admin_password" = var.admin_password
  "turn_secret" = random_password.turn_secret.result
  "jicofo_secret" = random_password.jicofo_secret.result
  "jicofo_focus_password" = random_password.jicofo_focus_password.result
  "jvb_secret" = random_password.jvb_secret.result
  "jvb_nickname" = random_id.jvb_nickname.hex
  "email" = var.email_address
  "public_ip" = var.host_ip
  })
}

resource "random_password" "turn_secret" {
  length = 8
  special = true
  override_special = "!@#$=-"
}

resource "random_password" "jicofo_secret" {
  length = 8
  special = true
  override_special = "!@#$=-"
}

resource "random_password" "jicofo_focus_password" {
  length = 8
  special = true
  override_special = "!@#$=-"
}

resource "random_password" "jvb_secret" {
  length = 8
  special = true
  override_special = "!@#$=-"
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

    source = "../playbooks"
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
    destination = "/tmp/playbooks/host_vars.json"
  }

  provisioner "remote-exec" {
    inline = ["ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python' --extra-vars '@/tmp/playbooks/host_vars.json' /tmp/playbooks/jitsi.yml"]
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

