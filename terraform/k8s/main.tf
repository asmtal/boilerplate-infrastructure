module "k8s_cluster" {
  source = "./cluster"

  region     = var.region
  project    = var.project
  network    = var.network
  subnetwork = var.subnetwork
}

module "k8s_config" {
  source = "./config"

  region  = var.region
  project = var.project
  cluster = module.k8s_cluster.cluster.name
  sql     = var.sql

  depends_on = [
    module.k8s_cluster
  ]
}
