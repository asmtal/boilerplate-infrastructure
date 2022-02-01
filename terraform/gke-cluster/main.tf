resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region

  initial_node_count       = 1
  remove_default_node_pool = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "gke_cluster_node_pool" {
  name     = "${google_container_cluster.gke_cluster.name}-node-pool"
  cluster  = google_container_cluster.gke_cluster.name
  location = var.region

  node_count = var.gke_cluster_node_count

  node_config {
    machine_type = "e2-small"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

## ---------- Networks ----------

resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
