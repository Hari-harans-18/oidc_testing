terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "trim-cistern-492506-c4"
  region  = "asia-south1"
}

resource "google_storage_bucket" "bucket" {
  name                        = "hari-terraform-demo-bucket-001"
  location                    = "asia-south1"
  uniform_bucket_level_access = true

  force_destroy = true
}
