# resource "google_compute_address" "static-ip" {
#   name = "static-ip-vm-${var.environment}"
#   address_type = "EXTERNAL"
#   network_tier = "PREMIUM"
# }

# resource "google_compute_instance" "test_instances" {
#   name         = "test-vm-${var.environment}"
#   machine_type = "e2-micro"
#   zone         = var.zone
  
#   service_account {
#     email = google_service_account.kubernetes_sa.email
#     scopes = ["cloud-platform"]
#   }
#   boot_disk {
#     initialize_params {
#       image = "ubuntu-2204-jammy-v20240927"
#     }
#   }

#   network_interface {
#     network = google_compute_network.vpc.id
#     subnetwork = data.google_compute_subnetwork.subnet.id
#     access_config {
#         nat_ip = google_compute_address.static-ip.address
#     }
#   }

#   lifecycle {
#     ignore_changes = [ metadata ]
#   }
# }

# output "test-instance-ip" {
#   value = google_compute_address.static-ip.address
# }