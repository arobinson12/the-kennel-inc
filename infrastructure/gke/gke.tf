# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "primary" {
  name                     = "super-cluster2"
  project                  = "bu1-prod-app"
  location                 = "us-central1-c"
  remove_default_node_pool = false
  initial_node_count       = 2
  network                  = "projects/prd-shared-host/global/networks/vpc-prod-shared"
  subnetwork               = "projects/prd-shared-host/regions/us-central1/subnetworks/subnet-bu1-1"
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"


  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "bu1-prod-app.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-svc"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  
  
    node_config {
    preemptible  = false
    machine_type = "e2-medium"

    labels = {
      role = "general"
    }

    service_account = "gke-sa@bu1-prod-app.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
    authenticator_groups_config {
      security_group = "gke-security-groups@ahmadrobinson.altostrat.com"
    }
  
     master_authorized_networks_config {
      cidr_blocks {
        cidr_block   = "10.0.0.0/8"
        display_name = "internal"
      }
    }
}
