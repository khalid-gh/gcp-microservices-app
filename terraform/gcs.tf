resource "google_storage_bucket" "terraform-state" {
  name                        = "${var.project_id}-demo-tfstate"
  storage_class               = "REGIONAL"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}
