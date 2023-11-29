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

variable "serverID" {
  type = string
  default = "1"
  description = "The ID of the server created by createServer module."
}
