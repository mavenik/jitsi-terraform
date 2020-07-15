locals {
  ansible_vars = jsonencode({
  "domain_name" = var.domain_name
  "turn_secret" = var.turn_secret
  "public_ip" = var.host_ip
  "realm" = var.realm
  "email" = var.email
  })
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

    source = "../playbooks/turn"
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
    destination = "/tmp/turn/host_vars.json"
  }

  provisioner "remote-exec" {
    inline = ["ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python' --extra-vars '@/tmp/turn/host_vars.json' /tmp/turn/turn.yml"]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = ["rm -rf /tmp/turn"]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.host_ip
      private_key = file(var.ssh_key_path)
    }
  }
}
