variable "image_path" {
  description = "Path to the base Ubuntu qcow2 image"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH (private) key"
  type        = string
}

variable "vm_memory" {
  description = "Memory per VM in MB"
  default     = 2048
}

variable "vm_vcpu" {
  description = "vCPUs per VM"
  default     = 2
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "ansible_dir" {
  description = "Path to the Ansible directory"
  type        = string
}

variable "ansible_user" {
  description = "Ansible SSH user"
  type        = string
}

variable "vm_disk_size_gb" {
  description = "Size of VM disk in GB"
  type        = number
  default     = 10
}

variable "ubuntu_base" {
  description = "Base Ubuntu image filename"
  type        = string
  default     = "ubuntu-24.04.qcow2"
}

variable "ubuntu_image_url" {
  description = "URL of the Ubuntu cloud image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}