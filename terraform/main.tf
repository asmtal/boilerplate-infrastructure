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
//  https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate
  )
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

## ---------- Modules ----------

module "gcp-bootstrap" {
  source = "./gcp-bootstrap"
  region = var.region
}

module "gke-cluster" {
  source       = "./gke-cluster"
  cluster_name = local.cluster_name
  region       = var.region
  project      = var.project
  depends_on   = [module.gcp-bootstrap]
}

module "kubernetes-config" {
  source       = "./kubernetes-config"
  cluster_name = local.cluster_name
  depends_on   = [module.gke-cluster]
}

## ---------- Locals ----------

locals {
  cluster_name = "${var.project}-gke"
}

## ---------- Data ----------

data "google_client_config" "default" {
  depends_on = [module.gke-cluster]
}

data "google_container_cluster" "default" {
  name       = local.cluster_name
  depends_on = [module.gke-cluster]
  location   = var.region
}
