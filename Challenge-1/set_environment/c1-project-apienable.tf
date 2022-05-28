
locals {
  project = (
    var.project_create ?
    {
      project_id = try(google_project.project.0.project_id, null)
    }
    : {
      project_id = try(data.google_project.project.0.project_id, null)
    }
  )
}

data "google_project" "project" {
  count      = var.project_create ? 0 : 1
  project_id = var.project_id
}

resource "random_id" "random_suffix" {
  byte_length = 6
}

# Create a Google project for Compute Engine

resource "google_project" "project" {
  count           = var.project_create ? 1 : 0
  billing_account = var.billing_account
  org_id          = var.org_id
  project_id      = "challenge-tf-${lower(random_id.random_suffix.hex)}"
  name            = "challenge-tf-${lower(random_id.random_suffix.hex)}"
}

# Enable the necessary services on the project for deployments
resource "google_project_service" "service" {
  for_each = toset(var.services)

  service = each.key

  project            = local.project.project_id
  disable_on_destroy = false
}
