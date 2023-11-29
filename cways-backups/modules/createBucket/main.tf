resource "google_storage_bucket" "cways-backup-bucket" {
  name          = var.bucket_name
  location      = "US"
  force_destroy = true
  public_access_prevention = "enforced"
  project = var.project-name
}


output "bucket-name" {
	value = google_storage_bucket.cways-backup-bucket.name
}