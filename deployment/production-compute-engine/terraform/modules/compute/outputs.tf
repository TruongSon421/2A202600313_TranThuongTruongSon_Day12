output "vm_name" {
  description = "Created VM name"
  value       = google_compute_instance.vm.name
}

output "vm_zone" {
  description = "Created VM zone"
  value       = google_compute_instance.vm.zone
}

output "vm_external_ip" {
  description = "VM public IP"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
