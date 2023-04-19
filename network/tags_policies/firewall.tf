resource "google_compute_firewall_policy" "load_balancer_hc" {
  parent    = "projects/prd-shared-host"
  name      = "load-balancer-health-check"
  short_name = "lbhc"
}

resource "google_compute_firewall_policy_rule" "allow_lb_hc" {
  firewall_policy = google_compute_firewall_policy.load_balancer_hc.id
  action          = "allow"
  priority        = 1000
  direction       = "INGRESS"
  enable_logging  = false
  match {
    layer4_config {
      ip_protocol = "tcp"
      ports       = ["80", "443"]
    }
  }

  target_tags = [
    google_compute_tag_value.frontend.value,
  ]

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
}
