resource "null_resource" "jitsi" {
  triggers = {
     instance_id = var.jitsi_public_ip
  }
  
  provisioner "remote-exec" {
    inline = ["echo \"Connected!\""]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.jitsi_public_ip
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -e ansible_python_interpreter=/usr/bin/python3 -i '${var.jitsi_public_ip},' --private-key ${var.ssh_key_path} -u ubuntu -e domain_name=meet.example.com ../packer/playbooks/jitsi.yml"
  }
}

resource "null_resource" "turn" {
  count = var.has_additional_turn ? 1 : 0
  triggers = {
     instance_id = var.additional_turn_public_ip
  }
  
  provisioner "remote-exec" {
    inline = ["echo \"Connected!\""]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = var.additional_turn_public_ip
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -e ansible_python_interpreter=/usr/bin/python3 -i '${var.additional_turn_public_ip},' --private-key ${var.ssh_key_path} -u ubuntu ../packer/playbooks/turn.yml"
  }
}
