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

resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "terraform-state-backend-${local.project}"
  location      = local.region
  force_destroy = true
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

terraform {
  backend "gcs" {
    bucket  = "terraform-state-backend-hackathon-438400"
    prefix  = "terraform/backend"
  }
}