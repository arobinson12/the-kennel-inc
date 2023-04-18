resource "google_compute_instance_template" "vm_template" {
  name_prefix  = "bu1-prod-app-instance-template-"
  project      = "bu1-prod-app"
  machine_type = "e2-medium"
  
  instance_description = "MIG instance"
  tags                 = ["mig-target"]

  disk {
    boot = true
    auto_delete = true
    source_image = "projects/debian-cloud/global/images/family/debian-10"
  }

  network_interface {
    network = "projects/prd-shared-host/global/networks/vpc-prod-shared"
    subnetwork = "projects/prd-shared-host/regions/us-central1/subnetworks/subnet-bu1-1"
  }

  service_account {
    email  = "generic-web@bu1-prod-app.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #! /bin/bash
    apt-get update
    apt-get install -y nginx
    echo "Hello from $(hostname). I'm a pet lover too!" > /var/www/html/index.html
    systemctl start nginx
  EOT

  labels = {
    business_unit = "bu1"
    approval_id   = "05012023"
  }
}

resource "google_compute_instance_group_manager" "vm_instance_group" {
  name        = "bu1-prod-app-instance-group"
  project     = "bu1-prod-app"
  base_instance_name = "bu1-prod-app-instance"
  zone        = "us-central1-c"

  version {
    instance_template = google_compute_instance_template.vm_template.self_link
  }

  target_size = 2
}
