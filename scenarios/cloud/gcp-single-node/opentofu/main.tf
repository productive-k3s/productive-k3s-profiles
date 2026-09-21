provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  server_name   = "${var.cluster_name}-server"
  rancher_host  = "rancher.${var.base_domain}"
  registry_host = "registry.${var.base_domain}"
  network_tags  = distinct(concat(var.tags, ["productive-k3s", var.cluster_name]))
}

data "google_compute_image" "ubuntu" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_firewall" "server" {
  name    = "${var.cluster_name}-server"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "6443"]
  }

  source_ranges = distinct([
    var.ssh_allowed_cidr,
    var.http_allowed_cidr,
    var.api_allowed_cidr,
  ])
  target_tags = local.network_tags
}

resource "google_compute_instance" "server" {
  name         = local.server_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = local.network_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork != "" ? var.subnetwork : null

    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOF
    #!/usr/bin/env bash
    set -euo pipefail
    printf 'Productive K3S GCP single-node server\n' >/etc/motd
  EOF

  labels = {
    product = "productive-k3s"
    usecase = "gcp-single-node"
  }
}
