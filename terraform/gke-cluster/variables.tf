variable "region" {}
variable "vpc_name" {}
variable "cluster_name" {
  type = string
}

variable "gke_cluster_node_count" {
  default = 1
}
