resource "google_compute_router" "router" {
  name    = "cr-nat"
  region  = "us-central1"
  network = module.vpc.network_name
}

resource "google_compute_router_nat" "nat" {
  name                               = "prod-nat"
  router                             = "cr-nat"
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
