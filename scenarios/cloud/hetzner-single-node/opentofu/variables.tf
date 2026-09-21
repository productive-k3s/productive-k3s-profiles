variable "hcloud_token" {
  description = "Hetzner Cloud API token."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Prefix used for the Hetzner single-node resources."
  type        = string
  default     = "productive-k3s-hetzner"
}

variable "base_domain" {
  description = "Internal DNS suffix used for Rancher and registry hostnames."
  type        = string
  default     = "k3s.lab.internal"
}

variable "remote_dir" {
  description = "Path inside the VM where productive-k3s will be copied."
  type        = string
  default     = "/root/productive-k3s-core"
}

variable "location" {
  description = "Hetzner Cloud location."
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Hetzner Cloud server type."
  type        = string
  default     = "cx32"
}

variable "image" {
  description = "Hetzner Cloud image."
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_key_name" {
  description = "Name for the SSH public key uploaded to Hetzner Cloud."
  type        = string
  default     = "productive-k3s"
}

variable "ssh_public_key_path" {
  description = "Local SSH public key path uploaded to Hetzner Cloud."
  type        = string
}

variable "ssh_user" {
  description = "Remote SSH user expected on the VM."
  type        = string
  default     = "root"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach TCP/22."
  type        = string
  default     = "0.0.0.0/0"
}

variable "http_allowed_cidr" {
  description = "CIDR allowed to reach TCP/80 and TCP/443."
  type        = string
  default     = "0.0.0.0/0"
}

variable "api_allowed_cidr" {
  description = "CIDR allowed to reach TCP/6443."
  type        = string
  default     = "0.0.0.0/0"
}
