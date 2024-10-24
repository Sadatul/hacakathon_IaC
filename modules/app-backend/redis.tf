resource "google_redis_instance" "redis_instance" {
  name           = "redis-instance-${var.environment}"
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  location_id = var.zone

  authorized_network = google_compute_network.vpc.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version = "REDIS_7_0"
  display_name  = "Redis Cache"
#   redis_configs = {
#     "notify-keyspace-events" = "Ex"
#   }
  depends_on = [google_service_networking_connection.private_service_access]
}

output "redis_host" {
  description = "The IP address of the redis instance."
  value       = google_redis_instance.redis_instance.host
}

output "redis_port" {
  description = "The port of the redis instance."
  value       = google_redis_instance.redis_instance.port
}
