variable "database_user_password" {
  type        = string
  description = "Password for the database"
  sensitive   = true
}

variable "database_user_username" {
  type        = string
  description = "Username for database"
  sensitive   = true
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