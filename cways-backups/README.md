# Remote GCP backups on Cloudways
Terraform project to configure remote backups on GCP bucket for a server created on Cloudways.
It includes the following Terraform modules:

1) Create GCP bucket:
   - Creates a new bucket to store backups 
2) Create backup script:
   - Creates a backup script to be used in a cron that will upload backups from Cloudways server to the remote bucket.
   - Bucket name is dynamic and passed to the backup script.  
3) Create a service account:
   - Creates a service account on GCP.
   - Provides service account access to the bucket created in the first module.
   - Creates a key to authenticate with GCP.
4) Create server:
   - Creates a new server on Cloudways.
   - Transfers backup script to the newly created server.
   - Installs GCP SDK on server.
   - Sets up cron to upload backups to GCP bucket.
