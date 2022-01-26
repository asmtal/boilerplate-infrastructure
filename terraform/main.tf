terraform {
  backend "gcs" {}
}

provider "google" {
  credentials = file("${path.module}/keyfile.json")
  project = var.project
}

resource "google_project_service" "cloudresourcemanager_service" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "artifactregistry_service" {
  service = "artifactregistry.googleapis.com"
}
