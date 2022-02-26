output "cluster" {
  value = module.k8s_cluster.cluster
}

output "data_container_cluster" {
  value = module.k8s_cluster.data_container_cluster
}

output "data_client_config" {
  value = module.k8s_cluster.data_client_config
}
