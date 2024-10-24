resource "google_service_account" "kubernetes_sa" {
  account_id   = "kubernetese-sa-${var.environment}"
  display_name = "K8s Service Account"
}

resource "google_project_iam_member" "cloudsql_client_for_proxy" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}

resource "google_project_iam_member" "secret_accessor_for_k8s_sa" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}

resource "google_project_iam_member" "logging_for_k8s_sa" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}

resource "google_project_iam_member" "monitoring_for_k8s_sa" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}

resource "google_project_iam_member" "tracing_for_k8s_sa" {
  project = var.project
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}

resource "google_project_iam_member" "consumer_for_k8s_sa" {
  project = var.project
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.kubernetes_sa.email}"
}
resource "google_service_account_key" "secret_accessor_key" {
  service_account_id = google_service_account.kubernetes_sa.name
  depends_on         = [google_project_iam_member.secret_accessor_for_k8s_sa]
}

output "secret_accessor_proxy_key" {
    value = google_service_account_key.secret_accessor_key.private_key
    sensitive = true
}

resource "google_container_cluster" "kubernetese_cluster" {
  name               = "kubernetese-cluster-${var.environment}"
  location           = var.zone
  initial_node_count = 1
  remove_default_node_pool = true
  
  network = google_compute_network.vpc.id
  subnetwork = data.google_compute_subnetwork.subnet.id

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  node_config {
    disk_size_gb = 50
  }

  lifecycle {
    ignore_changes = [ node_config[0].kubelet_config ]
  }

  deletion_protection = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool-${var.environment}"
  location   = var.zone
  cluster    = google_container_cluster.kubernetese_cluster.name
  node_count = 2

  node_config {
    # preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 50
    service_account = google_service_account.kubernetes_sa.email
  }

  lifecycle {
    ignore_changes = [ node_config[0].kubelet_config ]
  }
}