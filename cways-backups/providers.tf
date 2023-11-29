terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.7.0"
    }
  }

  backend "s3" {
    bucket = "tf-state-bk-007"
    key    = "terraform_projects/cwaysbackups/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-backend-lock-table"
    encrypt = true
    profile = "default"
  }
}

provider "google" {
  # Configuration options
  credentials = file("${var.terraform-credentials-file}")
  project     = var.project-name
  region      = var.region
  zone        = var.zone
}
