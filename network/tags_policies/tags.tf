resource "google_compute_tag_key" "app_svc" {
  key        = "app_svc"
  project_id = "prd-shared-host"
}

resource "google_compute_tag_value" "frontend" {
  parent = google_compute_tag_key.app_svc.self_link
  value  = "frontend"
}
