resource "google_secret_manager_secret" "db_password" {
  provider  = google
  secret_id = "db_password_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.database_user_password
}

resource "google_secret_manager_secret" "db_username" {
  provider  = google
  secret_id = "db_username_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_username_version" {
  secret      = google_secret_manager_secret.db_username.id
  secret_data = var.database_user_username
}

resource "google_secret_manager_secret" "db_url" {
  provider  = google
  secret_id = "db_url_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_url_version" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = var.database_url
}

resource "google_secret_manager_secret" "email_password" {
  provider  = google
  secret_id = "email_password_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "email_password_version" {
  secret      = google_secret_manager_secret.email_password.id
  secret_data = var.email_password
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "external" "convert_to_pkcs8" {
  program = ["bash", "-c", <<EOT
    echo "{\"pkcs8_key\": \"$(echo "${tls_private_key.rsa_key.private_key_pem}" | openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt | base64 -w 0)\"}"
  EOT
  ]
}

resource "google_secret_manager_secret" "rsa_public_key" {
  provider  = google
  secret_id = "rsa_public_key_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "rsa_public_key_version" {
  secret      = google_secret_manager_secret.rsa_public_key.id
  secret_data = tls_private_key.rsa_key.public_key_pem
}

resource "google_secret_manager_secret" "rsa_private_key" {
  provider  = google
  secret_id = "rsa_private_key_${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "rsa_private_key_version" {
  secret      = google_secret_manager_secret.rsa_private_key.id
  secret_data = base64decode(data.external.convert_to_pkcs8.result.pkcs8_key)
}
