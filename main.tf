terraform {
  required_version = ">= 0.12"
}
provider "google" {
  credentials = file(var.gcp_auth_file)
  project     = var.gcp_project
  region      = var.gcp_region
}

#provider "google" {
#  credentials = file(var.gcp_auth_file)
#  project = "interstellar-14"
#  region  = "us-central1"
#  zone    = "us-central1-c"
#}

module "vpc" {
  source                                 = "./network/vpc"
  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id
  description                            = var.description
  shared_vpc_host                        = var.shared_vpc_host
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  mtu                                    = var.mtu
}
