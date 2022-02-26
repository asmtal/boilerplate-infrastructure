resource "google_container_cluster" "gke_cluster" {
  name     = "${var.project}-gke-cluster"
  location = var.region

  initial_node_count       = 1
  remove_default_node_pool = true

  network    = var.network.self_link
  subnetwork = var.subnetwork.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = var.subnetwork.secondary_ip_range.0.range_name
    services_secondary_range_name = var.subnetwork.secondary_ip_range.1.range_name
  }
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
