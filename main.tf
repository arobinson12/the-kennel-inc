#terraform {
#  required_version = ">= 0.12"
#}
#provider "google" {
#  credentials = file(var.gcp_auth_file)
#  project     = var.gcp_project
#  region      = var.gcp_region
#}

provider "google" {
  credentials = file(var.gcp_auth_file)
  project = "interstellar-14"
  region  = "us-central1"
  zone    = "us-central1-c"
}

module "network" {
  source = "./network/vpc"
  
  project_id = var.project_id
  network_name = var.network_name
}
