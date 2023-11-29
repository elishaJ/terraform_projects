#!/bin/bash
cd ~;
/home/master/google-cloud-sdk/bin/gcloud auth login --cred-file=.tf-sa-identity.json --quiet;
for app in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do 
	cd /home/master/applications/$app/local_backups/; 
	/home/master/google-cloud-sdk/bin/gsutil cp backup.tgz gs://cways-backup-bucket/$app/backup-$(date +'%d-%m-%y_%H:%M').tgz; 
done
