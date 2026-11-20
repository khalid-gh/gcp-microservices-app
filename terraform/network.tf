module "vpc" {
  source       = "github.com/terraform-google-modules/terraform-google-network?ref=91352bed3014ddbfb323d979b6413a90e7253acf" # v18.3.1
  project_id   = var.project_id
  network_name = "gke-demo-vpc"

  subnets = [
    {
      subnet_name           = "gke-demo-subnet"
      subnet_ip             = "10.0.0.0/18"
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]

  secondary_ranges = {
    "gke-demo-subnet" = [
      {
        range_name    = "gke-demo-subnet-pods"
        ip_cidr_range = "10.48.0.0/14"
      },
      {
        range_name    = "gke-demo-subnet-services"
        ip_cidr_range = "10.52.0.0/20"
      }
    ]
  }

  ingress_rules = [
    {
      name          = "allow-iap-ssh-bastion"
      description   = "Allow IAP SSH to bastion"
      source_ranges = ["35.235.240.0/20"] # Google IAP TCP forwarding range
      target_tags   = ["bastion"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name          = "allow-cluster-bastion-proxy"
      description   = "Allow private GKE nodes and Pods to use the repository proxy"
      source_ranges = ["10.0.0.0/18", "10.48.0.0/14"]
      target_tags   = ["bastion"]
      allow = [{
        protocol = "tcp"
        ports    = ["3128"]
      }]
    }
  ]
}
