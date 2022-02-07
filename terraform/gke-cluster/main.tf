resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region

  initial_node_count       = 1
  remove_default_node_pool = true

  network    = var.vpc_name
  subnetwork = "${var.vpc_name}-subnet"
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

  lifecycle {
    create_before_destroy = true
  }
}
