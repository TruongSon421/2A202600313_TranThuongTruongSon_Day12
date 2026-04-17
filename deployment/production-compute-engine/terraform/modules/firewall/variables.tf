variable "firewall_name" {
  description = "Firewall rule name"
  type        = string
}

variable "network" {
  description = "Network name for firewall rule"
  type        = string
}

variable "network_tag" {
  description = "Target network tag"
  type        = string
}
