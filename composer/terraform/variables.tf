variable "project_id" {
  description = "The GCP project ID where the resources will be created."
  type        = string
}

variable "region" {
  description = "The region where the Cloud Composer environment will be created."
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account for Cloud Composer."
  type        = string
}

variable "composer_environment_name" {
  description = "The name of the Cloud Composer environment."
  type        = string
}
