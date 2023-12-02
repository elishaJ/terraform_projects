/* module "enableAPI" {
  source       = "./modules/enableAPI"
  project-name = var.project-name
} */

# Module for creating GCP bucket for offsite backup storage
module "createBucket" {
  source       = "./modules/createBucket"
  project-name = var.project-name
}

locals {
  bucket_name = module.createBucket.bucket-name
}

# Module for creating GCP Service Account
module "createServiceAccount" {
  source            = "./modules/createServiceAccount"
  cways-bucket-name = local.bucket_name
}

# Module for creating backup script
 module "createBackupScript" {
  source            = "./modules/createBackupScript"
  cways-bucket-name = local.bucket_name
}

# Module for creating server
 module "createServer" {
  source = "./modules/createServer"
  CW_API_KEY = var.CW_API_KEY
}