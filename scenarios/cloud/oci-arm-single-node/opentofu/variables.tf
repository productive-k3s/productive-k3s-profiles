variable "compartment_ocid" {
  description = "OCI compartment OCID used for the single ARM node."
  type        = string
}

variable "region" {
  description = "OCI region."
  type        = string
  default     = "us-ashburn-1"
}

variable "availability_domain" {
  description = "Optional OCI availability domain. Leave empty to use the first available domain."
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Prefix used for the OCI ARM single-node resources."
  type        = string
  default     = "productive-k3s-oci-arm"
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

variable "shape" {
  description = "OCI compute shape."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "OCPU count for flexible Ampere shapes."
  type        = number
  default     = 4
}

variable "memory_in_gbs" {
  description = "Memory size for flexible Ampere shapes."
  type        = number
  default     = 24
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GiB."
  type        = number
  default     = 100
}

variable "image_ocid" {
  description = "Ubuntu ARM64 image OCID compatible with the selected OCI region."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Local SSH public key path injected into instance metadata."
  type        = string
}

variable "ssh_user" {
  description = "Remote SSH user expected on the VM."
  type        = string
  default     = "ubuntu"
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
