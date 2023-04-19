
resource "google_compute_health_check" "https_health_check" {
  name                = "https-health-check"
  project             = "bu1-prod-app"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 3

  https_health_check {
    request_path = "/"
    port         = 80
  }
}

resource "google_compute_firewall" "health_check_allow" {
  name    = "allow-health-check"
  network = "projects/prd-shared-host/global/networks/vpc-prod-shared"
  project = "bu1-prod-app"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["mig-target"]
}

resource "google_compute_backend_service" "https_backend" {
  name        = "https-backend"
  project     = "bu1-prod-app"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10

  health_checks = [google_compute_health_check.https_health_check.self_link]

  backend {
    group = google_compute_instance_group_manager.vm_instance_group.self_link
  }
}

resource "google_compute_url_map" "https_url_map" {
  name    = "https-url-map"
  project = "bu1-prod-app"

  default_service = google_compute_backend_service.https_backend.self_link
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name    = "https-proxy"
  project = "bu1-prod-app"
  url_map      = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.managed_ssl_cert.self_link]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name        = "https-forwarding-rule"
  project     = "bu1-prod-app"
  target      = google_compute_target_https_proxy.https_proxy.self_link
  port_range  = "443"
  ip_protocol = "TCP"
}

resource "google_compute_managed_ssl_certificate" "managed_ssl_cert" {
  project = var.project_id
  name    = "example-managed-ssl-cert"
  managed {
    domains = ["thekennelinc.com"]
  }
}
