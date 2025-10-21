terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Réseau interne Kubernetes
resource "libvirt_network" "k8s" {
  name      = "k8s-net"
  mode      = "nat"
  addresses = ["192.168.100.0/24"]
}

# Volume de base (image cloud-init Ubuntu)
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  source = var.image_path
  format = "qcow2"
}

# Template de création de VM
locals {
  nodes = [
    { name = "k8s-master", ip = "192.168.100.10" },
    { name = "k8s-worker-1", ip = "192.168.100.11" },
    { name = "k8s-worker-2", ip = "192.168.100.12" },
  ]
}

resource "libvirt_volume" "vm_disk" {
  for_each = { for node in local.nodes : node.name => node }
  name     = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
}

resource "libvirt_domain" "vm" {
  for_each = { for node in local.nodes : node.name => node }

  name   = each.key
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  network_interface {
    network_id   = libvirt_network.k8s.id
    hostname     = each.key
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.user_data[each.key].id

  console {
    type        = "pty"
    target_port = "0"
  }
}

# Cloud-init : user_data pour SSH et config
resource "libvirt_cloudinit_disk" "user_data" {
  for_each = { for node in local.nodes : node.name => node }
  name     = "${each.key}-cloudinit.iso"

  user_data = <<EOF
#cloud-config
hostname: ${each.key}
ssh_authorized_keys:
  - ${file(var.ssh_pubkey_path)}
package_update: true
package_upgrade: true
EOF
}
