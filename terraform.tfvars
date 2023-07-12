project_id = "prd-shared-host"

network_name = "vpc-prod-shared"

shared_vpc_host = true

subnets = [
          {
            subnet_name           = "subnet-bu1-1"
            subnet_ip             = "10.100.1.0/24"
            subnet_region         = "us-central1"
            subnet_private_access = "true"
            description           = "Subnet for BU1 resources"
        },
         {
            subnet_name           = "subnet-bu2-1"
            subnet_ip             = "10.200.1.0/24"
            subnet_region         = "us-central1"
            subnet_private_access = "true"
            description           = "Subnet for BU2 resources"
        }
]

secondary_ranges = {
        subnet-bu1-1 = [
            {
                range_name    = "gke-svc"
                ip_cidr_range = "10.110.0.0/26"
            },
            {
                range_name    = "gke-pods"
                ip_cidr_range = "10.110.128.0/17"
            }
        ]
    }


routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
]

# The below three variable must be updated for the PoC
organization_id = "85360846529"
billing_account = "01243C-F08778-AC2391"
proxy_access_identities = "user:admin@ahmadrobinson.altostrat.com"



# Below variable can be update per customer use cases
folder_name = "Security Foundation Sol "
demo_project_id = "sf-sol-poc-" 
vpc_network_name = "host-network"
network_region = "us-east1"
network_zone = "us-east1-b"

keyring_name = "my-keyring"
crypto_key_name = "my-symmetric-key"

labels = {
  asset_type = "prod"
}