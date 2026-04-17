locals {
  startup_script_content = <<-EOT
    #!/usr/bin/env bash
    set -euxo pipefail

    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release git

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$${VERSION_CODENAME}") stable" > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    if id -u ubuntu >/dev/null 2>&1; then
      usermod -aG docker ubuntu || true
    fi
  EOT
}

module "network" {
  source = "./modules/network"

  network_name    = var.network
  subnetwork_name = var.subnetwork
}

module "firewall" {
  source = "./modules/firewall"

  firewall_name = var.firewall_name
  network       = module.network.network_name
  network_tag   = var.network_tag
}

module "compute" {
  source = "./modules/compute"

  vm_name             = var.vm_name
  machine_type        = var.machine_type
  zone                = var.zone
  boot_disk_size_gb   = var.boot_disk_size_gb
  boot_disk_type      = var.boot_disk_type
  network_name        = module.network.network_name
  subnetwork_name     = module.network.subnetwork_name
  network_tag         = var.network_tag
  ssh_user            = var.ssh_user
  ssh_public_key      = var.ssh_public_key
  startup_script_content = local.startup_script_content
  use_spot_instance   = var.use_spot_instance
}
