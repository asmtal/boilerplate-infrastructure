output "network" {
  value = google_compute_network.private_network
}

output "subnetwork" {
  value = google_compute_subnetwork.private_network_subnet
}
