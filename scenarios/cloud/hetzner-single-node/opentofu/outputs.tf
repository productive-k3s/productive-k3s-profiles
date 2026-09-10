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

output "location" {
  value = var.location
}

output "ssh_user" {
  value = var.ssh_user
}

output "instance_id" {
  value = hcloud_server.server.id
}

output "instance_name" {
  value = hcloud_server.server.name
}

output "server_type" {
  value = hcloud_server.server.server_type
}

output "public_ip" {
  value = hcloud_server.server.ipv4_address
}

output "private_ip" {
  value = ""
}

output "datacenter" {
  value = var.location
}

output "firewall_id" {
  value = hcloud_firewall.server.id
}
