locals {
  project = "hackathon-438400"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}

provider "google-beta" {
  project = local.project
  region  = local.region
  zone    = local.zone
}


terraform {
  backend "gcs" {
    bucket = "terraform-state-backend-hackathon-438400"
    prefix = "terraform/prod"
  }
}

data "local_file" "auth_file" {
  filename = "${path.module}/auth" 
}

module "app_backend" {
  source = "../modules/app-backend"

  environment            = "prod"
  project                = local.project
  region                 = local.region
  zone                   = local.zone
  database_user_password = var.database_user_password
  database_user_username = var.database_user_username
  # database_url           = var.database_url
  email_password         = var.email_password
  zipkin_auth            = trimspace(data.local_file.auth_file.content)
}
# output "auth" {
#   value = base64encode(trimspace(data.local_file.auth_file.content))
# }

# output "auth2" {
#   value = module.app_backend.zipkin_output
# }

output "database_ip" {
  value = module.app_backend.authservice_database_ip
}

output "redis-host" {
  value = "${module.app_backend.redis_host}:${module.app_backend.redis_port}"
}

output "ingress-static-ip" {
  value = module.app_backend.static_ip_address
}

# output "test-instance-static-ip" {
#   value = module.app_backend.test-instance-ip
# }
# resource "local_file" "secret_accessor_key_file" {
#   content_base64  = module.app_backend.secret_accessor_proxy_key
#   filename        = "${path.module}/secret_accessor_key.json"
#   file_permission = "0600"
# }