output "network_name" {
  description = "Resolved network name"
  value       = data.google_compute_network.selected.name
}

output "network_self_link" {
  description = "Resolved network self_link"
  value       = data.google_compute_network.selected.self_link
}

output "subnetwork_name" {
  description = "Optional subnetwork to use"
  value       = var.subnetwork_name
}
