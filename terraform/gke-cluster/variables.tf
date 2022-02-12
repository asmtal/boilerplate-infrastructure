variable "region" {}
variable "private_vpc_network" {}
variable "private_vpc_subnetwork" {}
variable "cluster_name" {
  type = string
}

variable "gke_cluster_node_count" {
  default = 1
}
