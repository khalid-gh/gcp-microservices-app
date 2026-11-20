variable "project_id" {
  type        = string
  description = "GCP project ID to deploy resources into"
}

variable "region" {
  type        = string
  description = "GCP region to deploy resources into"
  default     = "europe-west2"
}

variable "services" {
  type        = set(string)
  description = "Google APIs to enable"
  default = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
  validation {
    condition     = alltrue(flatten([[for service in var.services : service != "" && endswith(service, "googleapis.com") ? true : false]]))
    error_message = "Service must end with .googleapis.com"
  }
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)"
  default = [
    { cidr_block = "10.0.0.0/18", display_name = "gke-demo-subnet" }
  ]
}
