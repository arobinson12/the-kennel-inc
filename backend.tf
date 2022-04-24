terraform {
  backend "gcs" {
    bucket  = "ar-tf-state"
    prefix  = "tf-state"
  }
}
