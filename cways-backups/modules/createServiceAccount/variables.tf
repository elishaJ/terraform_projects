variable "project-name" {
  type        = string
  default     = "friendly-chat-22d17"
  description = "The name of the GCP project in which the service account will be created"
}

variable "cways-bucket-name" {
  type = string
}
