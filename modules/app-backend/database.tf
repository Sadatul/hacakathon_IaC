resource "google_sql_database_instance" "database_instance" {
  name             = "database-instance-${var.environment}"
  region = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.private_service_access]
  settings {
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }

  }
  deletion_protection = false
}

resource "google_sql_database" "authservice_database" {
  name     = "authservice-database"
  instance = google_sql_database_instance.database_instance.name
}

resource "google_sql_user" "authservice_database_user" {
  name     = "${var.database_user_username}"
  instance = google_sql_database_instance.database_instance.name
  password = "${var.database_user_password}"
  host     = "%"
}

output "authservice_database_ip" {
  value     = google_sql_database_instance.database_instance.ip_address.0.ip_address
}
