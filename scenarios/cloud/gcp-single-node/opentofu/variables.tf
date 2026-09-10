variable "project_id" {
  description = "Google Cloud project id used for the VM."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Google Cloud zone."
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Prefix used for the GCP single-node resources."
  type        = string
  default     = "productive-k3s-gcp"
}

variable "base_domain" {
  description = "Internal DNS suffix used for Rancher and registry hostnames."
  type        = string
  default     = "k3s.lab.internal"
}

variable "remote_dir" {
  description = "Path inside the VM where productive-k3s will be copied."
  type        = string
  default     = "/home/ubuntu/productive-k3s-core"
}

variable "machine_type" {
  description = "GCP Compute Engine machine type."
  type        = string
  default     = "e2-standard-4"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GiB."
  type        = number
  default     = 80
}

variable "ssh_user" {
  description = "Remote SSH user expected on the VM."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Local SSH public key path injected into VM metadata."
  type        = string
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

variable "network" {
  description = "GCP network name or self link."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Optional GCP subnetwork name or self link."
  type        = string
  default     = ""
}

variable "image_project" {
  description = "GCP image project used to resolve Ubuntu."
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = "GCP image family used to resolve Ubuntu."
  type        = string
  default     = "ubuntu-2404-lts-amd64"
}

variable "tags" {
  description = "Network tags applied to the VM."
  type        = list(string)
  default     = []
}
