variable "environment" {
  type      = string
  description = "The environment for the deployments"
  validation {
    condition = var.environment == "qa" || var.environment == "prod"
    error_message = "Invalid envrionment name"
  }
}

variable "project" {
  type      = string
  description = "The projectId"
}

variable "region" {
  type      = string
  description = "The region"
}

variable "zone" {
  type      = string
  description = "The Zone"
}

variable "database_user_password" {
  type      = string
  description = "Password for the database"
  sensitive = true
}

variable "database_user_username" {
  type      = string
  description = "Username for database"
  sensitive = true
}

variable "database_url" {
  type      = string
  description = "Url for database"
  sensitive = true
}

variable "email_password" {
  type      = string
  description = "Email Password"
  sensitive = true
}

variable "zipkin_auth" {
  description = "Username for basic Zipkin auth"
  type        = string 
  sensitive = false
}