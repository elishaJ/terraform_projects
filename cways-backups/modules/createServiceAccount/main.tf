resource "google_service_account" "service_account" {
  account_id   = "terraform-service-account"
  display_name = "Terraform-Service Account"
  project = var.project-name
  description = "Terraform Service Account for GCP authentication "
  }

output "service-account" {
	value = google_service_account.service_account.email
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = var.cways-bucket-name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account_key" "key" {
  service_account_id = google_service_account.service_account.name
}

resource "local_file" "myaccountjson" {
content     = base64decode(google_service_account_key.key.private_key)
filename = "${path.root}.tf-sa-identity.json"
file_permission = "0600"
}