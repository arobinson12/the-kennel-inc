resource "google_tags_tag_key" "apptype" {
  parent      = "organizations/85360846529"
  short_name  = "apptype"
  description = "For apptype resources."
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