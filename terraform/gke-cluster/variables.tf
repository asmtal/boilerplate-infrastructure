variable "project" {}
variable "region" {}
variable "cluster_name" {
  type = string
}

variable "gke_cluster_node_count" {
  default = 1
}
