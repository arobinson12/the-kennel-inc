# terraform {
#   required_version = ">= 0.12"
# }

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.32.0" # tftest
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.32.0" # tftest
    }
  }
}
#provider "google" {
#  credentials = file(var.gcp_auth_file)
#  project     = var.gcp_project
#  region      = var.gcp_region
#}

provider "google" {
#  credentials = file(var.gcp_auth_file)
  project = "interstellar-14"
  region  = "us-central1"
  zone    = "us-central1-c"
  alias = "service"
    impersonate_service_account = google_service_account.terraform_service_account.email
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
