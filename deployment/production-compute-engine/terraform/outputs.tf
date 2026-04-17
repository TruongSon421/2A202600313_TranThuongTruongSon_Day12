output "vm_name" {
  value       = module.compute.vm_name
  description = "Created Compute Engine VM name"
}

output "vm_zone" {
  value       = module.compute.vm_zone
  description = "Zone of the created VM"
}

output "vm_external_ip" {
  value       = module.compute.vm_external_ip
  description = "Public IP of the created VM"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${module.compute.vm_name} --zone ${module.compute.vm_zone}"
  description = "Convenient SSH command"
}

output "firewall_name" {
  value       = module.firewall.firewall_name
  description = "Firewall rule protecting HTTP ingress"
}
