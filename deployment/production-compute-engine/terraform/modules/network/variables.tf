variable "network_name" {
  description = "VPC network name to use"
  type        = string
}

variable "subnetwork_name" {
  description = "Optional subnetwork name"
  type        = string
  default     = null
}
