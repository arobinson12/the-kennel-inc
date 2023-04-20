
resource "google_tags_tag_key" "apptype" {
  parent      = "organizations/85360846529"
  short_name  = "apptype"
  description = "For apptype resources."
  purpose     = "GCE_FIREWALL"

  purpose_data {
    network = "prd-shared-host/vpc-prod-shared"
  }
}

resource "google_tags_tag_value" "web" {
  parent      = "tagKeys/${google_tags_tag_key.apptype.name}"
  short_name  = "web"
  description = "For web resources."
}

resource "google_compute_network_firewall_policy" "primary" {
  name        = "policy"
  project     = "prd-shared-host"
  description = "Sample global network firewall policy"
}

resource "google_compute_network_firewall_policy_rule" "primary" {
  action                  = "allow"
  description             = "This is a simple rule description"
  project                 = "prd-shared-host"
  direction               = "INGRESS"
  disabled                = false
  enable_logging          = true
  firewall_policy         = google_compute_network_firewall_policy.primary.name
  priority                = 1000
  rule_name               = "test-rule"
  target_service_accounts = ["generic-web@bu1-prod-app.iam.gserviceaccount.com"]

  match {
    src_ip_ranges = ["35.235.240.0/20"]

    src_secure_tags {
      name = "tagValues/${google_tags_tag_value.web.name}"
    }

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["22"]
    }
  }
}

resource "google_compute_instance" "proxy_1" {
  name         = "proxy-1"
  project      = "bu1-prod-app"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  
  service_account {
    email  = "generic-web@bu1-prod-app.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "projects/prd-shared-host/global/networks/vpc-prod-shared"
    subnetwork = "projects/prd-shared-host/regions/us-central1/subnetworks/subnet-bu1-1"
  }
}

#resource "google_tags_tag_binding" "binding" {
#  parent    = "//compute.googleapis.com/projects/bu1-prod-app/zones/us-central1-a/instances/${google_compute_instance.proxy_1.name}"
#  tag_value = "tagValues/${google_tags_tag_value.web.name}"
#}
