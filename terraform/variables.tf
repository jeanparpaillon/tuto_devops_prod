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