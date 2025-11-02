terraform {
  required_providers {
   ansible = {
      source = "ansible/ansible"
      version = "1.3.0"
    }
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

# Pool de stockage des images
resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"

  # Chemin où seront stockées les images
  path = "/var/lib/libvirt/images"
}

# Volume de base (image cloud-init Ubuntu)
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04.qcow2"
  pool   = libvirt_pool.default.name
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Template de création de VM
locals {
  base_nodes = [
    { role = "master" },
    { role = "worker" },
    { role = "worker" },
  ]

  # Ajout d'un nom unique
  nodes_named = flatten([
    for role in distinct([for n in local.base_nodes : n.role]) : [
      for idx, n in [
        for n in local.base_nodes : n if n.role == role
      ] : merge(n, {
        name = format("%s-%s-%d", var.cluster_name, n.role, idx + 1),
        cluster = var.cluster_name
      })
    ]
  ])

  # Séparation par rôle
  workers = [for n in local.nodes_named : n if n.role == "worker"]
  masters  = [for n in local.nodes_named : n if n.role == "master"]

  # Liste complète, master en premier
  nodes = concat(local.masters, local.workers)
}

resource "libvirt_volume" "vm_disk" {
  for_each = { for node in local.nodes : node.name => node }
  name     = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size = 10 * 1024 * 1024 * 1024  # 10 GB
}

resource "libvirt_domain" "vm" {
  for_each = { for node in local.nodes : node.name => node }

  name   = each.key
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  network_interface {
    network_name   = libvirt_network.k8s.name
    hostname     = each.key
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.user_data[each.key].id

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  console {
    type        = "pty"
    target_port = "0"
  }
}

resource "libvirt_cloudinit_disk" "user_data" {
  for_each = { for node in local.nodes : node.name => node }
  name     = "${each.key}-cloudinit.iso"

  user_data = <<EOF
#cloud-config
hostname: ${each.key}
ssh_authorized_keys:
  - ${file(join(".", [var.ssh_key_path, "pub"]))}
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
growpart:
  mode: auto
  devices: ['/']
EOF
}

resource "ansible_group" "masters" {
  name = "masters"
}

resource "ansible_group" "workers" {
  name = "workers"
}

resource "ansible_host" "nodes" {
  for_each = { for node in local.nodes : node.name => node }

  name   = each.key
  groups  = [each.value.role == "master" ? ansible_group.masters.name : ansible_group.workers.name]

  variables = {
    # Connection vars.
    ansible_user = var.ansible_user
    ansible_host = libvirt_domain.vm[each.key].network_interface[0].addresses[0]
    ansible_ssh_private_key_file = var.ssh_key_path
    ansible_python_interpreter = "/usr/bin/python3"
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    role = each.value.role
    cluster = each.value.cluster
  }
}

output "nodes" {
  value = ansible_host.nodes
  sensitive = false
}
