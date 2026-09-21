provider "hcloud" {
  token = var.hcloud_token
}

locals {
  server_name   = "${var.cluster_name}-server"
  rancher_host  = "rancher.${var.base_domain}"
  registry_host = "registry.${var.base_domain}"
}

resource "hcloud_ssh_key" "server" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_firewall" "server" {
  name = "${var.cluster_name}-server"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [var.ssh_allowed_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = [var.http_allowed_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = [var.http_allowed_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = [var.api_allowed_cidr]
  }
}

resource "hcloud_server" "server" {
  name        = local.server_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.server.id]
  firewall_ids = [
    hcloud_firewall.server.id,
  ]

  user_data = <<-EOF
    #cloud-config
    package_update: false
    package_upgrade: false
    manage_etc_hosts: true
    write_files:
      - path: /etc/motd
        content: |
          Productive K3S Hetzner single-node server
  EOF

  labels = {
    product = "productive-k3s"
    usecase = "hetzner-single-node"
  }
}
