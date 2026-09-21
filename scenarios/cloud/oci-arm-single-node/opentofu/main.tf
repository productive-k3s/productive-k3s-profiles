provider "oci" {
  region = var.region
}

locals {
  server_name   = "${var.cluster_name}-server"
  rancher_host  = "rancher.${var.base_domain}"
  registry_host = "registry.${var.base_domain}"
}

data "oci_identity_availability_domains" "available" {
  compartment_id = var.compartment_ocid
}

locals {
  selected_availability_domain = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.available.availability_domains[0].name
}

resource "oci_core_vcn" "server" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.cluster_name}-vcn"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "pk3s"
}

resource "oci_core_internet_gateway" "server" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.server.id
  display_name   = "${var.cluster_name}-igw"
}

resource "oci_core_route_table" "server" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.server.id
  display_name   = "${var.cluster_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.server.id
  }
}

resource "oci_core_security_list" "server" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.server.id
  display_name   = "${var.cluster_name}-sl"

  ingress_security_rules {
    protocol = "6"
    source   = var.ssh_allowed_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.http_allowed_cidr
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.http_allowed_cidr
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.api_allowed_cidr
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "server" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.server.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${var.cluster_name}-subnet"
  dns_label                  = "server"
  route_table_id             = oci_core_route_table.server.id
  security_list_ids          = [oci_core_security_list.server.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_instance" "server" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.selected_availability_domain
  display_name        = local.server_name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.server.id
    assign_public_ip = true
    display_name     = "${local.server_name}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(<<-EOF
      #!/usr/bin/env bash
      set -euo pipefail
      printf 'Productive K3S OCI ARM single-node server\n' >/etc/motd
    EOF
    )
  }

  freeform_tags = {
    Product = "productive-k3s"
    UseCase = "oci-arm-single-node"
  }
}
