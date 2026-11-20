resource "google_artifact_registry_repository" "gke-demo-images" {
  project       = var.project_id
  location      = var.region
  repository_id = "gke-demo-images"
  description   = "Mirrored images for private GKE nodes"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "node-reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.gke-demo-images.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.gke.service_account}"
}
