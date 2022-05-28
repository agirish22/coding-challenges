resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create Cloud SQL instance

resource "google_sql_database_instance" "feedback" {
  name             = local.cloud_sql_instance_name
  database_version = var.database_version
  region           = var.region
  project          = local.project.project_id

  deletion_protection = false

  settings {

    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.feedback-network.id
    }

  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Create a database instance

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.feedback.name
  project  = local.project.project_id
}

# Set the root password

resource "random_password" "mysql_root" {
  length  = 16
  special = true
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.feedback.name
  type     = "BUILT_IN"
  project  = local.project.project_id
  password = random_password.mysql_root.result
}

