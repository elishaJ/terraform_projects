variable "terraform-credentials-file" {
  type        = string
  default     = "/home/ali/.creds/terraform-service-account-credentials.json"
  description = "Service account used by Terraform to authenticate to GCP"
}

variable "project-name" {
  type        = string
  default     = "friendly-chat-22d17"
  description = "The name of the GCP project in which the resources will be created"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default region for GCP project"
}

variable "zone" {
  type        = string
  default     = "us-central1-c"
  description = "Default zone for GCP project"
}

variable "cloudways_apikey_file_path" {
  type        = string
  #default     = "/home/ali/.creds/cways_api_key"
  default     = "/home/ali/.creds/cways_api_key1"
  description = "Cloudways API key path for server deployment"
}

variable "cloudways-email" {
  type        = string
  #default     = "elisha.jamil@cloudways.com"
  default     = "rana.rehman@cloudways.com"
  description = "Cloudways primary account email"
}