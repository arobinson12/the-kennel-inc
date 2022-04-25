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

module "subnets" {
  source           = "./network/subnets"
  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

  module "routes" {
  source            = "./network/routes"
  project_id        = var.project_id
  network_name      = module.vpc.network_name
  routes            = var.routes
  module_depends_on = [module.subnets.subnets]
}

locals {
  rules = [
    for f in var.firewall_rules : {
      name                    = f.name
      direction               = f.direction
      priority                = lookup(f, "priority", null)
      description             = lookup(f, "description", null)
      ranges                  = lookup(f, "ranges", null)
      source_tags             = lookup(f, "source_tags", null)
      source_service_accounts = lookup(f, "source_service_accounts", null)
      target_tags             = lookup(f, "target_tags", null)
      target_service_accounts = lookup(f, "target_service_accounts", null)
      allow                   = lookup(f, "allow", [])
      deny                    = lookup(f, "deny", [])
      log_config              = lookup(f, "log_config", null)
    }
  ]
}

module "firewall_rules" {
  source       = "./network/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name
  rules        = local.rules
}

module "nat" {
  source       = "./network/nat"
  network_name      = module.vpc.network_name
  project_id   = var.project_id
}

# ******************************************************
# ******************************************************
# GKE
# ******************************************************
# ******************************************************

locals {
  cluster_type = "shared-vpc"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "./infrastructure/gke"
  project_id                 = var.bu1_project_id
  name                       = "super-cluster2"
  region                     = "us-central1"
  network                    = module.vpc.network_name
  network_project_id         = var.project_id
  subnetwork                 = "subnet-bu1-1"
  ip_range_pods              = "subnet-pods"
  ip_range_services          = "subnet-svc"
  create_service_account     = false
  service_account            = "gke-sa@bu1-prod-app.iam.gserviceaccount.com"
  add_cluster_firewall_rules = true
  firewall_inbound_ports     = ["9443", "15017"]
}
