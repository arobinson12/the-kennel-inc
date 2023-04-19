resource "google_compute_tag_key" "app_svc" {
  parent     = "projects/${var.project_id}"
  tag_key_id = "app_svc"
  description = "App service tag key"
}

resource "google_compute_tag_value" "frontend" {
  parent     = google_compute_tag_key.app_svc.name
  tag_value_id = "frontend"
  description  = "Frontend tag value"
}
