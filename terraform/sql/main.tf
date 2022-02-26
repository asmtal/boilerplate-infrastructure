resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "database_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_sql_database_instance" "sql_instance" {
  name                = "sql-instance-${random_id.db_name_suffix.hex}"
  database_version    = "MYSQL_5_7"
  deletion_protection = false

  settings {
    tier = "db-n1-standard-2"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network.id
    }
  }
}

resource "google_sql_database" "sql_database" {
  name      = "sql-database"
  instance  = google_sql_database_instance.sql_instance.name
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "sql_root_user" {
  name     = "root"
  password = random_password.database_root_password.result
  instance = google_sql_database_instance.sql_instance.name
}

