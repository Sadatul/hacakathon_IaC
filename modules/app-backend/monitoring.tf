resource "google_service_account" "monitoring_sa" {
  account_id   = "monitoring-sa-${var.environment}"
  display_name = "Service Account for monitoring"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.monitoring_sa.email}"
}