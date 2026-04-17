variable "vm_name" {
  description = "Compute Engine VM name"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
}

variable "zone" {
  description = "GCP zone for VM"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork_name" {
  description = "Optional subnetwork name"
  type        = string
  default     = null
}

variable "network_tag" {
  description = "Network tag on VM"
  type        = string
}

variable "ssh_user" {
  description = "Linux username for SSH key metadata"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "startup_script_content" {
  description = "Startup script content"
  type        = string
}

variable "use_spot_instance" {
  description = "Whether this instance should be Spot"
  type        = bool
}
