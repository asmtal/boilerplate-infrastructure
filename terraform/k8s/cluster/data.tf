data "google_client_config" "default" {
  depends_on = [google_container_cluster.gke_cluster]
}

data "google_container_cluster" "default" {
  name       = google_container_cluster.gke_cluster.name
  location   = var.region
  depends_on = [google_container_cluster.gke_cluster]
}
