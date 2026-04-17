resource "google_compute_firewall" "allow_http" {
  name    = var.firewall_name
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = [var.network_tag]
  direction   = "INGRESS"
}
