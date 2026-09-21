output "cluster_name" {
  value = var.cluster_name
}

output "base_domain" {
  value = var.base_domain
}

output "remote_dir" {
  value = var.remote_dir
}

output "rancher_host" {
  value = local.rancher_host
}

output "registry_host" {
  value = local.registry_host
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "ssh_user" {
  value = var.ssh_user
}

output "instance_id" {
  value = google_compute_instance.server.id
}

output "instance_name" {
  value = google_compute_instance.server.name
}

output "machine_type" {
  value = google_compute_instance.server.machine_type
}

output "public_ip" {
  value = google_compute_instance.server.network_interface[0].access_config[0].nat_ip
}

output "private_ip" {
  value = google_compute_instance.server.network_interface[0].network_ip
}

output "network" {
  value = var.network
}

output "subnetwork" {
  value = var.subnetwork
}
