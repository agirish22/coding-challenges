resource "google_secret_manager_secret" "feedback-secret" {
  provider  = google-beta
  project   = local.project.project_id
  secret_id = "feedback-token"

  labels = {
    label = "feedback-sql-connect"
  }

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "feedback-secret-version" {
  provider = google-beta
  secret   = google_secret_manager_secret.feedback-secret.id
  secret_data = jsonencode({
    "DB_USER" = "root"
    "DB_PASS" = random_password.mysql_root.result
    "DB_NAME" = var.database_name
    "DB_HOST" = "${google_sql_database_instance.feedback.private_ip_address}:3306"
  })
}


resource "google_secret_manager_secret_iam_member" "feedback-secret-member" {
  provider  = google-beta
  project   = local.project.project_id
  secret_id = google_secret_manager_secret.feedback-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}

locals {
  instance_name = "feedback-runner-vm"
}


module "mig_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 7.0"
  project_id         = local.project.project_id
  machine_type       = var.machine_type
  network            = var.network_name
  subnetwork         = var.subnet_name
  region             = var.region
  subnetwork_project = local.project.project_id
  service_account = {
    email = google_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 10
  disk_type            = "pd-ssd"
  auto_delete          = true
  name_prefix          = var.instance_name
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  startup_script       = file("${path.module}/scripts/startup.sh")
  source_image         = var.source_image
  metadata = {
    "secret-id" = google_secret_manager_secret_version.feedback-secret-version.name
  }
  tags = [
    "feedback-runner-vm", "allow-http"
  ]
}


module "mig" {
  source             = "terraform-google-modules/vm/google//modules/mig"
  version            = "~> 7.0"
  project_id         = local.project.project_id
  subnetwork_project = local.project.project_id
  hostname           = var.instance_name
  region             = var.region
  instance_template  = module.mig_template.self_link
  target_size        = var.target_size

  autoscaling_enabled = true
  cooldown_period     = var.cooldown_period
}
