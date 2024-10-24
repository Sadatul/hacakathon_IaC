resource "google_project_service" "compute_engine_api" {
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "service_networking_api" {
  service = "servicenetworking.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "sqladmin-api" {
  service = "sqladmin.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "secret_manager_api" {
  service = "secretmanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "kubernetes_api" {
  service = "container.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "redis_admin_api" {
  service = "redis.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}