variable "image_path" {
  description = "Path to the base Ubuntu qcow2 image"
  type        = string
}

variable "ssh_pubkey_path" {
  description = "Path to SSH public key"
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
