## ---------- Networking ----------

resource "random_id" "vpc_name_suffix" {
  byte_length = 4
}

resource "google_compute_network" "private_network" {
  name                    = "vpc-network-${random_id.vpc_name_suffix.hex}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_network_subnet" {
  name                     = "vpc-subnetwork-default"
  network                  = google_compute_network.private_network.self_link
  ip_cidr_range            = "10.210.0.0/16"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "192.168.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "192.170.0.0/16"
  }

  depends_on = [
    google_compute_network.private_network
  ]
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "${google_compute_network.private_network.name}-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.240.0.0"
  prefix_length = 16
  network       = google_compute_network.private_network.id

  depends_on = [
    google_compute_network.private_network
  ]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [
    google_compute_network.private_network,
    google_compute_global_address.private_ip_range
  ]
}

