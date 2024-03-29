# Root main.tf

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

module "gke" {
  source       = "./infrastructure/gke"
}

module "cloud_run_app" {
  source              = "./labs/cloud_run_app"
  project_id          = "bu1-prod-app"
  shared_vpc_project_id = "prd-shared-host"
  shared_vpc_name     = "vpc-prod-shared"
  region              = "us-central1"
  ip_range            = "10.90.0.0/28"
}
  
#module "mig" {
#  source = "./infrastructure/gce"
#}

#module "global_load_balancer" {
#  source = "./network/loadbalancer"
#  mig_instance_group = module.mig.instance_group_url
#}

# module "custom_firewall" {
#  source = "./network/tags-firewall"
#}

# module "sf-poc" {
#   source                  = "./labs/sf-poc/security-foundation-solution"

#   organization_id = "85360846529"
#   billing_account = "01243C-F08778-AC2391"
#   proxy_access_identities = "user:admin@ahmadrobinson.altostrat.com"

#   folder_name = "Security Foundation Sol "
#   demo_project_id = "sf-sol-poc-" 
#   vpc_network_name = "host-network"
#   network_region = "us-east1"
#   network_zone = "us-east1-b"

#   keyring_name = "my-keyring"
#   crypto_key_name = "my-symmetric-key"

#   labels = {
#     asset_type = "prod"
#   }
# }