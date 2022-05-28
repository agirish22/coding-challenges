
variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "us-central1-a"
}

variable "project_create" {
  description = "Create project. When set to false, uses a data source to reference existing project. "
  type        = bool
  default     = false
}

variable "project_id" {
  description = "Project id (also used for the Apigee Organization)."
  type        = string
}

variable "billing_account" {
  type        = string
  default     = ""
  description = "Billing account to associate with the project being created."
}

variable "org_id" {
  type        = string
  default     = ""
  description = "Organization ID to associate with the project being created"
}

variable "services" {
  type        = list(string)
  description = "List of services to enable for project"
  default = [
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

variable "prefix" {
  type        = string
  description = "Prefix for naming the project and other resources"
  default     = "feedback"
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "feedback-network"
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = "10.10.10.0/24"
}
variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "feedback-subnet"
}

variable "database_version" {
  type        = string
  description = "Database version for app"
  default     = "MYSQL_5_7"
}

variable "database_tier" {
  type        = string
  description = "Database tier for app"
  default     = "db-f1-micro"
}

variable "database_name" {
  type        = string
  description = "Name of database for app"
  default     = "feedback"
}

variable "instance_name" {
  type        = string
  description = "The gce instance name"
  default     = "feedback"
}

variable "target_size" {
  type        = number
  description = "The number of runner instances"
  default     = 1
}

variable "machine_type" {
  type        = string
  description = "The GCP machine type to deploy"
  default     = "n1-standard-1"
}

variable "source_image_family" {
  type        = string
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Ubuntu image."
  default     = "ubuntu-minimal-1804-lts"
}

variable "source_image_project" {
  type        = string
  description = "Project where the source image comes from"
  default     = "ubuntu-os-cloud"
}

variable "source_image" {
  type        = string
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  default     = ""
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}
