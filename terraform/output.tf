output "database_host" {
  value     = module.sql.database_host
  sensitive = true
}

output "database_name" {
  value     = module.sql.database_name
  sensitive = true
}

output "database_password" {
  value     = module.sql.database_password
  sensitive = true
}

output "cluster_name" {
  value = module.k8s.cluster.name
}
