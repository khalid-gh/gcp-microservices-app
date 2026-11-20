resource "google_compute_instance" "bastion" {
  name         = "gke-bastion"
  machine_type = "e2-medium"
  zone         = "${var.region}-b"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      size  = 10
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = "gke-demo-subnet"
    access_config {} # ephemeral public IP for outbound internet access
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["bastion"]
}
