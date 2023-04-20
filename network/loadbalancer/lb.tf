resource "google_compute_backend_service" "mig_backend_service" {
  name        = "mig-backend-service"
  project     = "bu1-prod-app"
  protocol    = "HTTPS"

  backend {
    group = google_compute_instance_group_manager.vm_instance_group.instance_group
  }

  health_checks = [
    google_compute_health_check.vm_health_check.self_link
  ]

  enable_cdn = false
}

resource "google_compute_health_check" "vm_health_check" {
  name     = "vm-health-check"
  project  = "bu1-prod-app"
  timeout_sec = 1
  check_interval_sec = 10

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_url_map" "mig_url_map" {
  name        = "mig-url-map"
  project     = "bu1-prod-app"

  default_service = google_compute_backend_service.mig_backend_service.self_link
}

resource "google_compute_target_https_proxy" "mig_https_proxy" {
  name             = "mig-https-proxy"
  project          = "bu1-prod-app"
  url_map          = google_compute_url_map.mig_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.self_link]
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name    = "mig-ssl-certificate"
  project = "bu1-prod-app"

  managed {
    domains = ["thekennel.com"]
  }
}

resource "google_compute_global_forwarding_rule" "mig_forwarding_rule" {
  name       = "mig-forwarding-rule"
  project    = "bu1-prod-app"
  target     = google_compute_target_https_proxy.mig_https_proxy.self_link
  port_range = "443"

  ip_address = google_compute_global_address.mig_global_address.address
}

resource "google_compute_global_address" "mig_global_address" {
  name    = "mig-global-address"
  project = "bu1-prod-app"
}
