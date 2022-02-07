output "sql_root_password" {
  value     = random_password.sql_root_password.result
  sensitive = true
}
