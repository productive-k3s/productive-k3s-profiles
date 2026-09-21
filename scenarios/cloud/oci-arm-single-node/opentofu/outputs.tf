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

output "availability_domain" {
  value = local.selected_availability_domain
}

output "ssh_user" {
  value = var.ssh_user
}

output "instance_id" {
  value = oci_core_instance.server.id
}

output "instance_name" {
  value = oci_core_instance.server.display_name
}

output "shape" {
  value = oci_core_instance.server.shape
}

output "public_ip" {
  value = oci_core_instance.server.public_ip
}

output "private_ip" {
  value = oci_core_instance.server.private_ip
}

output "vcn_id" {
  value = oci_core_vcn.server.id
}

output "subnet_id" {
  value = oci_core_subnet.server.id
}
