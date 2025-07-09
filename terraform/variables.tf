variable "project_id" {
    description = "Google Cloud Project ID"
    type = string
}

variable "region" {
    description = "Region to deploy Cloud Run"
    type = string
    default = "us-central1"
}
