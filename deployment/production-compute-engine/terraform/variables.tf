variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-southeast1-b"
}

variable "vm_name" {
  description = "Compute Engine VM name"
  type        = string
  default     = "ai-agent-vm"
}

variable "machine_type" {
  description = "Compute Engine machine type"
  type        = string
  default     = "e2-medium"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Boot disk type: pd-standard (cheaper) or pd-balanced (faster)"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork name. Keep null to use auto subnet from default VPC."
  type        = string
  default     = null
}

variable "network_tag" {
  description = "Network tag used by firewall and VM"
  type        = string
  default     = "ai-agent-web"
}

variable "firewall_name" {
  description = "Firewall rule name"
  type        = string
  default     = "allow-ai-agent-http"
}

variable "ssh_user" {
  description = "Linux username for SSH metadata key"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key content (single line, without trailing newline)"
  type        = string
}

variable "use_spot_instance" {
  description = "Use Spot VM to reduce cost. May be terminated by GCP."
  type        = bool
  default     = true
}
