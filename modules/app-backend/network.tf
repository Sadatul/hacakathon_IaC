resource "google_compute_network" "vpc" {
  project                 = var.project # Replace this with your project ID in quotes
  name                    = "my-vpc-${var.environment}"
  auto_create_subnetworks = true
  mtu                     = 1460
}

resource "google_compute_firewall" "vpc-firewal" {
  name    = "project-firewall-${var.environment}"
  network = google_compute_network.vpc.name
  direction = "INGRESS"
  priority = 65534
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}

data "google_compute_subnetwork" "subnet" {
  name   = google_compute_network.vpc.name
  region = var.region
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_access" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_address" "ingress_ip" {
  name = "ingress-ip-${var.environment}"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

output "static_ip_address" {
  value       = google_compute_address.ingress_ip.address
  description = "The static IP address"
}