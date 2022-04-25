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
