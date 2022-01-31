output "kubeconfig_path" {
  value = abspath("${path.root}/kubeconfig")
}

output "cluster_host" {
  value = data.google_container_cluster.default.endpoint
}
