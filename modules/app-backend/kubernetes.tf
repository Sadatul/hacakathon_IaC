data "google_client_config" "default" {}

data "google_container_cluster" "kubernetes_cluster" {
  name     = google_container_cluster.kubernetese_cluster.name
  location = google_container_cluster.kubernetese_cluster.location

  depends_on = [google_container_cluster.kubernetese_cluster]
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.kubernetes_cluster.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.kubernetes_cluster.master_auth[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.kubernetes_cluster.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.kubernetes_cluster.master_auth[0].cluster_ca_certificate)
  }
}

resource "kubernetes_config_map" "otel_config" {
  metadata {
    name = "otel-config"
    namespace = "default"
  }
  data = {
    "config.yaml" = file("${path.module}/otel-collector-config.yaml")  # Replace with your local file path
  }
}

resource "kubernetes_config_map" "main-config" {
  metadata {
    name      = "main-config"
    namespace = "default"
  }

  data = {
    REDIS_SERVICE_HOST = google_redis_instance.redis_instance.host
    # BACKEND_HOST                    = "http://${google_compute_global_address.pinklife_line_ip.address}"
    BACKEND_HOST  = "https://api.pinklifeline.xyz"
    FRONTEND_HOST = "https://www.pinklifeline.xyz"
    ZIPKIN_HOST = "http://zipkin:9411"
  }

  depends_on = [google_container_cluster.kubernetese_cluster]
}

resource "kubernetes_secret" "sa_secret" {
  metadata {
    name      = "sa-secret"
    namespace = "default"
  }

  type = "Opaque"

  data = {
    "sm-sa.json" = base64decode(google_service_account_key.secret_accessor_key.private_key)
  }

  depends_on = [
    google_service_account_key.secret_accessor_key,
    google_container_cluster.kubernetese_cluster
  ]
}

# resource "null_resource" "generate_htpasswd" {
#   triggers = {
#     username = var.zipkin_username
#     password = var.zipkin_password
#   }

#   provisioner "local-exec" {
#     command = "htpasswd -nb ${var.zipkin_username} ${var.zipkin_password} > .htpasswd"
#   }
# }

# resource "kubernetes_secret" "zipink_secret" {
#   metadata {
#     name      = "zipkin-secret"
#     namespace = "default"
#   }

#   type = "Opaque"

#   data = {
#     auth = var.zipkin_auth
#   }

#   depends_on = [
#     google_service_account_key.secret_accessor_key,
#     google_container_cluster.kubernetese_cluster
#   ]
# }

output "zipkin_output" {
  value = base64encode(var.zipkin_auth)
}

locals {
  name = "ksa"
  namespace = "default"
}

resource "kubernetes_service_account" "ksa" {
  metadata {
    name = local.name
    namespace = local.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.kubernetes_sa.email}"
    }
  }
  
}

resource "google_service_account_iam_binding" "gsa_binding" {
  service_account_id = google_service_account.kubernetes_sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${local.namespace}/${local.name}]"
  ]
}

resource "google_service_account_iam_binding" "metric_writer_binding" {
  service_account_id = google_service_account.monitoring_sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[gmp-system/collector]"
  ]

  depends_on = [ google_container_cluster.kubernetese_cluster ]
}

data "kubernetes_service_account" "collector" {
  metadata {
    name      = "collector"
    namespace = "gmp-system"
  }
}

resource "kubernetes_annotations" "collector_annotations" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = data.kubernetes_service_account.collector.metadata[0].name
    namespace = data.kubernetes_service_account.collector.metadata[0].namespace
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = "${google_service_account.monitoring_sa.email}"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = google_compute_address.ingress_ip.address
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.13.0"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}