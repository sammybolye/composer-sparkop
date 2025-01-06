provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Enable Composer API
resource "google_project_service" "composer_api" {
  project = var.project_id
  service = "composer.googleapis.com"
  disable_on_destroy = false
}

# Service Account for Cloud Composer nodes
resource "google_service_account" "custom_service_account" {
  account_id   = var.service_account_name
  display_name = "Example Custom Service Account"
}

resource "google_project_iam_member" "composer_worker_role" {
  project = var.project_id
  member  = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  role    = "roles/composer.worker"
}

resource "google_project_iam_member" "secret_manager_accessor_role" {
  project = var.project_id
  member  = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  role    = "roles/secretmanager.secretAccessor"
}

# Add the required roles to the default Composer Service Account
resource "google_project_iam_member" "composer_default_sa_role" {
  project = var.project_id
  member  = "serviceAccount:composer-sa@${var.project_id}.iam.gserviceaccount.com"
  role    = "roles/composer.worker"
}

resource "google_project_iam_member" "composer_default_sa_secret_role" {
  project = var.project_id
  member  = "serviceAccount:composer-sa@${var.project_id}.iam.gserviceaccount.com"
  role    = "roles/secretmanager.secretAccessor"
}

# Cloud Composer environment
resource "google_composer_environment" "example_environment" {
  name   = var.composer_environment_name
  region = var.region

  config {
    software_config {
      image_version = "composer-3-airflow-2.10.2-build.4"
      airflow_config_overrides = {
        secrets-backend = "airflow.providers.google.cloud.secrets.secret_manager.CloudSecretManagerBackend"
      }
    }
    node_config {
      service_account = google_service_account.custom_service_account.email
    }
  }
}

output "airflow_secret_backend" {
  description = "The Airflow secret backend configuration."
  value       = google_composer_environment.example_environment.config[0].software_config[0].airflow_config_overrides["secrets-backend"]
}

output "composer_dags_folder" {
  description = "The Google Cloud Storage bucket path for the Composer environment's DAGs folder."
  value       = google_composer_environment.example_environment.config[0].dag_gcs_prefix
}
