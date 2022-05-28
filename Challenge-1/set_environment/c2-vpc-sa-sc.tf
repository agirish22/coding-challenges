resource "random_id" "id" {
  byte_length = 4
  prefix      = var.prefix
}

locals {
  gcp_service_account_name = "${var.prefix}-feedback-app"
  cloud_sql_instance_name  = "${random_id.id.hex}-db"
}

# Create a service account - used by instances so that they have permission to access the secret that is in secret manager

resource "google_service_account" "service_account" {
  account_id   = local.gcp_service_account_name
  display_name = local.gcp_service_account_name
  project      = local.project.project_id
}

# Create a VPC for the application
resource "google_compute_network" "feedback-network" {
  name                    = var.network_name
  project                 = local.project.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "feedback-subnetwork" {
  project       = local.project.project_id
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = google_compute_network.feedback-network.name
}

resource "google_compute_router" "default" {
  name    = "${var.network_name}-router"
  network = google_compute_network.feedback-network.self_link
  region  = var.region
  project = local.project.project_id
}

resource "google_compute_router_nat" "nat" {
  project                            = local.project.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "http" {
  project     = local.project.project_id
  name        = "${var.network_name}-http-allow"
  network     = google_compute_network.feedback-network.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["allow-http"]
}

# Private IP address for Cloud SQL  

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  project  = local.project.project_id

  name          = "feedback-db-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.feedback-network.id
}

# Private IP connection for DB

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.feedback-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
