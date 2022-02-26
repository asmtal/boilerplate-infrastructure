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
  host  = "https://${module.k8s.data_container_cluster.endpoint}"
  token = module.k8s.data_client_config.access_token
  cluster_ca_certificate = base64decode(
    module.k8s.data_container_cluster.master_auth[0].cluster_ca_certificate
  )
}

## ---------- Modules ----------

module "__init" {
  source = "./__init"

  region = var.region
}

module "networking" {
  source = "./networking"

  depends_on = [
    module.__init
  ]
}

module "sql" {
  source = "./sql"

  network = module.networking.network

  depends_on = [
    module.__init,
    module.networking
  ]
}

module "k8s" {
  source = "./k8s"

  region     = var.region
  project    = var.project
  network    = module.networking.network
  subnetwork = module.networking.subnetwork
  sql        = module.sql

  depends_on = [
    module.__init,
    module.networking,
    module.sql
  ]
}

module "__temporary__" {
  source = "./__temporary__"

  region     = var.region
  network    = module.networking.network
  subnetwork = module.networking.subnetwork

  depends_on = [
    module.networking
  ]
}

## ---------- Connectivity Test - instance -> sql ----------

# Terraform has a bug - does not allow to pass "--destination-cloud-sql-instance",
#   so I have to refer to the instance via IP addresses.
resource "google_network_management_connectivity_test" "instance_to_sql_test" {
  name     = "instance-to-sql-test"
  protocol = "TCP"

  source {
    ip_address = module.__temporary__.instance.network_interface.0.network_ip
  }

  destination {
    ip_address = module.sql.instance.private_ip_address
    network    = module.networking.network.self_link
    port       = 3306
  }
}
