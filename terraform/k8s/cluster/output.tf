output "cluster" {
  value = google_container_cluster.gke_cluster
}

output "data_container_cluster" {
  value = data.google_container_cluster.default
}

output "data_client_config" {
  value = data.google_client_config.default
}
