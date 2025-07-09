provider "google" {
  project = var.project_id
  region  = var.region
}
 
resource "google_cloud_run_service" "nginx" {
  name     = "cicd-challenge"
  location = var.region
 
  template {
    spec {
      containers {
        image = "oeuvre13/cicd-challenge:latest"
        ports {
          container_port = 8080
        }
      }
    }
 
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "3"
      }
    }
  }
 
  traffic {
    percent         = 100
    latest_revision = true
  }
}
 
resource "google_cloud_run_service_iam_member" "noauth" {
  location = var.region
  project  = var.project_id
  service  = google_cloud_run_service.nginx.name
 
  role   = "roles/run.invoker"
  member = "allUsers"
}
