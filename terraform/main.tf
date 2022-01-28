terraform {
  backend "gcs" {}
}

provider "google" {
  credentials = file("${path.module}/keyfile.json")
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  credentials = file("${path.module}/keyfile.json")
  project     = var.project
  region      = var.region
}

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

## Kubernetes

resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "gke_cluster" {
  name     = "${var.project}-gke"
  location = var.region

  initial_node_count       = 1
  remove_default_node_pool = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "gke_cluster_node_pool" {
  name    = "${google_container_cluster.gke_cluster.name}-node-pool"
  cluster = google_container_cluster.gke_cluster.name

  node_count = var.gke_cluster_node_count
  location   = var.region

  node_config {
    machine_type = "e2-micro"
  }
}
