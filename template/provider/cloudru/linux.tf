variable "linux_vm_config" {
  type = map(object({
    name               = string
    os_image           = string
    private_ip_address = string
    password           = string
    size               = string
  }))

  default = {
    {{linux_vms}}
  }
}

resource "tls_private_key" "linux_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "sbercloud_compute_instance" "linux_goad_vm" {
  for_each = var.linux_vm_config

  name               = "{{lab_name}}-${each.value.name}"
  region             = var.region
  image_name         = each.value.os_image
  flavor_id          = each.value.size
  admin_pass         = each.value.password
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]

  system_disk_type = "SAS"
  system_disk_size = 60

  user_data = templatefile("${path.module}/instance-init-linux.yml.tpl", {
    username = var.username
    password = each.value.password
    key      = tls_private_key.linux_ssh.public_key_openssh
  })

  network {
    uuid        = sbercloud_vpc_subnet.goad_subnet.id
    fixed_ip_v4 = each.value.private_ip_address
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.linux_ssh.private_key_pem}' > ../ssh_keys/${each.value.name}_ssh.pem && chmod 600 ../ssh_keys/${each.value.name}_ssh.pem"
  }
}
