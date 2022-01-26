terraform {
  backend "gcs" {}
}

provider "google" {
  credentials = file("${path.module}/keyfile.json")
  project = var.project
}

provider "google-beta" {
  credentials = file("${path.module}/keyfile.json")
  project = var.project
}

resource "google_project_service" "cloudresourcemanager_service" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "artifactregistry_service" {
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "frontend_repository" {
  provider = google-beta

  location = var.region
  repository_id = "frontend"
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "backend_repository" {
  provider = google-beta

  location = var.region
  repository_id = "backend"
  format = "DOCKER"
}