resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = [var.network_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  metadata = {
    ssh-keys       = "${var.ssh_user}:${var.ssh_public_key}"
    startup-script = var.startup_script_content
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible                 = var.use_spot_instance
    provisioning_model          = var.use_spot_instance ? "SPOT" : "STANDARD"
    automatic_restart           = var.use_spot_instance ? false : true
    instance_termination_action = var.use_spot_instance ? "STOP" : null
  }
}
