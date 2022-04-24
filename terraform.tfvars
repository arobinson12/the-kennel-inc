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
        }
]

routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
]
