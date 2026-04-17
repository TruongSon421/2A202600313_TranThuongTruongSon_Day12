output "firewall_name" {
  description = "Created firewall rule name"
  value       = google_compute_firewall.allow_http.name
}
