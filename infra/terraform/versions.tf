terraform {
  required_version = ">= 1.6.0"

  # Remote state. Local state is unsafe for teams (state loss, merge conflicts,
  # secrets on disk), so state lives in a GCS bucket. This is a partial backend:
  # supply the bucket/prefix at init time so the module stays reusable, e.g.
  #   terraform init -backend-config=backend.hcl
  # See backend.hcl.example. The bucket must exist (with versioning enabled)
  # before the first init.
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}
