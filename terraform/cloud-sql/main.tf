resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "sql_instance" {
  provider = google-beta

  name                = "sql-instance-${random_id.db_name_suffix.hex}"
  database_version    = "MYSQL_8_0"
  root_password       = var.root_password
  deletion_protection = false

  settings {
    tier = "db-n1-standard-2"
    ip_configuration {
      private_network = var.private_network_id
    }
  }

  depends_on = [var.private_vpc_connection]
}

resource "google_sql_database" "sql_database" {
  name      = "sql-database"
  instance  = google_sql_database_instance.sql_instance.name
  charset   = "utf8"
  collation = "utf8_general_ci"
}