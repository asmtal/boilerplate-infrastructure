resource "google_project_service" "cloudresourcemanager_service" {
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "artifactregistry_service" {
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "compute_service" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "container_service" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "project_repository" {
  provider = google-beta

  location      = var.region
  repository_id = "project"
  format        = "DOCKER"
}
