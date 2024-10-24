locals {
  project     = "hackathon-438400"
  region      = "asia-southeast1"
  zone        = "asia-southeast1-a"
}

provider "google" {
  project     = local.project
  region      = local.region
  zone        = local.zone
}

terraform {
  backend "gcs" {
    bucket  = "terraform-state-backend-hackathon-438400"
    prefix  = "terraform/global"
  }
}
