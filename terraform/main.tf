terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.8.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
  }
}

## ---------- Providers ----------

//TODO: Use the official names of environment variables (for project, region, etc.).
//  Maybe there is even an environment variable that stores the keyfile json file.
//  https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference

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

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate
  )
}

## ---------- Modules ----------

module "gcp-init" {
  source = "./gcp-init"
  region = var.region
}

module "cloud-sql" {
  source              = "./cloud-sql"
  private_vpc_network = google_compute_network.private_network
  root_password       = random_password.sql_root_password.result
  depends_on = [
    google_compute_network.private_network,
    google_service_networking_connection.private_vpc_connection
  ]
}

module "gke-cluster" {
  source                 = "./gke-cluster"
  cluster_name           = local.cluster_name
  region                 = var.region
  private_vpc_network    = google_compute_network.private_network
  private_vpc_subnetwork = google_compute_subnetwork.private_network_subnet
  depends_on = [
    module.cloud-sql,
    google_compute_network.private_network,
    google_compute_subnetwork.private_network_subnet
  ]
}

module "k8s-config" {
  source       = "./k8s-config"
  cluster_name = local.cluster_name
  project      = var.project
  region       = var.region
  depends_on   = [module.gke-cluster]
}

## ---------- Networking ----------

resource "google_compute_network" "private_network" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_network_subnet" {
  name          = "${local.vpc_name}-subnet"
  network       = google_compute_network.private_network.self_link
  ip_cidr_range = "10.20.0.0/24"
  depends_on    = [google_compute_network.private_network]
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.30.0.0"
  prefix_length = 16
  network       = google_compute_network.private_network.id
  depends_on    = [google_compute_network.private_network]
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

## ---------- Locals ----------

locals {
  cluster_name = "${var.project}-gke"
  vpc_name     = "${var.project}-vpc"
}

## ---------- Data ----------

resource "random_password" "sql_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "google_client_config" "default" {
  depends_on = [module.gke-cluster]
}

data "google_container_cluster" "default" {
  name       = local.cluster_name
  location   = var.region
  depends_on = [module.gke-cluster]
}

// temporary (for private network tests only):
resource "google_compute_instance" "gcp_instance" {
  name                      = "instance-1"
  machine_type              = "e2-micro"
  zone                      = "${var.region}-a"
  allow_stopping_for_update = true
  tags                      = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = google_compute_network.private_network.self_link
    subnetwork = google_compute_subnetwork.private_network_subnet.self_link
  }

  depends_on = [
    google_compute_network.private_network,
    google_compute_subnetwork.private_network_subnet
  ]
}

resource "google_compute_firewall" "firewall_rule_ssh" {
  name          = "firewall-rule-ssh"
  network       = google_compute_network.private_network.self_link
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.private_network
  ]
}
