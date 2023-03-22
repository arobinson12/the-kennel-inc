variable "project_id" {}
variable "shared_vpc_project_id" {}
variable "shared_vpc_name" {}
variable "region" {}
variable "ip_range" {}

locals {
  connector_subnet_name = "serverless-connector-subnet"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Granting this BU1 project access to the shared VPC

resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  host_project      = var.shared_vpc_project_id
  service_project   = var.project_id
}

# Service accounts needed for the app

resource "google_project_iam_member" "elixir_app_identity_platform" {
  project = var.project_id
  role    = "roles/identityplatform.admin"
  member  = "serviceAccount:${google_service_account.elixir_app.email}"
}

resource "google_project_iam_member" "elixir_app_sdk_admin" {
  project = var.project_id
  role    = "roles/identityplatform.admin"
  member  = "serviceAccount:${google_service_account.elixir_app.email}"
}

# Creating the subnet for the connector
resource "google_compute_subnetwork" "serverless_vpc_connector_subnet" {
  provider      = google-beta
  name          = "serverless-connector-subnet"
  ip_cidr_range = "10.90.0.0/28"
  region        = "us-central1"
  network       = "projects/${var.shared_vpc_project_id}/global/networks/${var.shared_vpc_name}"
  
  depends_on = [
    google_compute_shared_vpc_service_project.shared_vpc_attachment,
  ]
}

# Creating the VPC connector
resource "google_vpc_access_connector" "serverless_vpc_connector" {
  name          = "serverless-vpc-connector"
  region        = "us-central1"
  ip_cidr_range = "10.90.0.0/28"
  project       = var.project_id

  network = "projects/${var.shared_vpc_project_id}/global/networks/${var.shared_vpc_name}"

  depends_on = [google_compute_subnetwork.serverless_vpc_connector_subnet]
}



# Creating the cloud run app
resource "google_cloud_run_service" "elixir_app" {
  name     = "elixir-app"
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" : "10"
        "run.googleapis.com/vpc-access-connector" : google_vpc_access_connector.serverless_vpc_connector.name
      }
    }

    spec {
      containers {
        image = "gcr.io/${var.project_id}/sample-login-app"
      }
      service_account_name = google_service_account.elixir_app.email
    }
  }
}


# Making the Cloud Run app available to public
resource "google_cloud_run_service_iam_member" "public" {
  provider = google-beta

  service  = google_cloud_run_service.elixir_app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Attaching SA to CR app
resource "google_service_account" "elixir_app" {
  account_id   = "elixir-app"
  display_name = "Elixir App Service Account"
}


# Identity Platform tenant and microsoft config. Need to add tenant id, client secret, and secret version resource name

#resource "google_identity_platform_tenant" "tenant" {
#  display_name = "Elixir App Tenant"
#  project      = var.project_id
#}

#resource "google_identity_platform_tenant_oauth_idp_config" "microsoft_ad" {
#  display_name  = "Microsoft AD"
#  enabled       = true
#  tenant        = google_identity_platform_tenant.tenant.name
#  client_id     = "your_microsoft_ad_client_id"
#  issuer        = "https://login.microsoftonline.com/your_tenant_id/v2.0"
#  client_secret = {
#    secret_manager_secret_version = "your_microsoft_ad_client_secret_version_resource_name"
#  }
#}

# Load Balancer. Need to add domain to SSL cert and URL map

resource "google_compute_global_address" "load_balancer_ip" {
  name          = "elixir-app-load-balancer-ip"
  purpose       = "EXTERNAL"
  address_type  = "EXTERNAL"
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "elixir-app-ssl-cert"
  managed {
    domains = ["elixir.example.com"]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "elixir-app-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

resource "google_compute_forwarding_rule" "https" {
  name        = "elixir-app-https-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "443"

  load_balancing_scheme = "EXTERNAL"
  target          = google_compute_target_https_proxy.https_proxy.self_link
  ip_address      = google_compute_global_address.load_balancer_ip.address
}

resource "google_compute_backend_service" "backend" {
  name        = "elixir-app-backend-service"
  protocol    = "HTTP2"
  timeout_sec = 10

  backend {
    group = google_cloud_run_service.elixir_app.status[0].url
  }
}

resource "google_compute_url_map" "url_map" {
  name = "elixir-app-url-map"

  default_service = google_compute_backend_service.backend.self_link

  host_rule {
    hosts        = ["elixir.example.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.backend.self_link
  }
}
