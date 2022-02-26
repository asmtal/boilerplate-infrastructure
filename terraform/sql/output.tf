output "instance" {
  value = google_sql_database_instance.sql_instance
}

output "database_host" {
  value     = google_sql_database_instance.sql_instance.private_ip_address
  sensitive = true
}

output "database_name" {
  value     = google_sql_database.sql_database.name
  sensitive = true
}

output "database_password" {
  value     = random_password.database_root_password.result
  sensitive = true
}
