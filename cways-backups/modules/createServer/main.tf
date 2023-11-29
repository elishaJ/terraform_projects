# Terraform resource to create a server on Cloudways
resource "null_resource" "createServer" {
  provisioner "local-exec" {
    command = <<-EOT
      #set -x  # Enable debug mode
      clear
      _bold=$(tput bold)
      _underline=$(tput sgr 0 1)
      _red=$(tput setaf 1)
      _green=$(tput setaf 76)
      _blue=$(tput setaf 38)
      _reset=$(tput sgr0)

      dir=$(pwd)
      mkdir -p .tmp_files/.ssh

      _success()
      {
        printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
      }

      _error() {
          printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
      }

      _note()
      {
          printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
      }

      email=${var.cloudways-email}
      api_key=$(cat "${var.cloudways_apikey_file_path}")
      
      # Generate access token
      get_accessToken(){
      access_token=$(curl -s -H "Accept: application/json" \
                       -H "Content-Type: application/json" \
                       -X POST \
                       -d '{"email": "'"$email"'", "api_key": "'"$api_key"'"}' \
                          'https://api.cloudways.com/api/v1/oauth/access_token' | jq -r '.access_token')
      }
      get_accessToken;

      # Define server parameters in Terraform variables inside the data field
      server_creation_data='{"cloud": "${var.cloud}", "region": "${var.server_region}", "instance_type": "${var.instance_type}", "application": "${var.app_type}", "app_version": "${var.app_version}", "server_label": "${var.server_label}", "app_label": "${var.app_label}"}'

      sleep 5;
      
      # Create server
      createServer() {
      curl -s -X POST \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "Authorization: Bearer $access_token" \
        -d "$server_creation_data" \
        'https://api.cloudways.com/api/v1/server' > $dir/.tmp_files/tf-new-server.json
      }
      createServer;

      # Store new server ID
      server_id=$(jq -r .server.id $dir/.tmp_files/tf-new-server.json);
      #echo ServerID: $server_id;
      export TF_VAR_serverID=$server_id;

      # Operation ID
      op_id=$(jq -r .operation_id $dir/.tmp_files/tf-new-server.json);
      
      # Put script to sleep during server creation process
      sleep 450;

      # Check server creation operation status
      get_opStatus() {
      curl -s -X GET \
        -H 'Accept: application/json' \
        -H "Authorization: Bearer $access_token" \
        'https://api.cloudways.com/api/v1/operation/'$op_id'' > $dir/.tmp_files/operation.json
      }
      get_opStatus;

      # Check operation status until it completes
      while [ "$(jq -r '.operation | .is_completed' $dir/.tmp_files/operation.json)" = "0" ]; do
        _note "The operation: $(jq -r '.operation | .id' $dir/.tmp_files/operation.json) is still running."
        _note "Putting the script to sleep.."
        echo ""
        sleep 30
        _note "Trying again..."
        get_opStatus;
      done
      _success "Server created sucessfully"

      get_serverInfo() {
        curl -s -X GET \
        -H 'Accept: application/json' \
        -H "Authorization: Bearer $access_token" \
        'https://api.cloudways.com/api/v1/server' > $dir/.tmp_files/servers.json
      }
      get_serverInfo;
      
      srvIP=$(jq -r '.servers[] | select(.id == "'$server_id'") | .public_ip' $dir/.tmp_files/servers.json)
      sshUser=$(jq -r '.servers[] | select(.id == "'$server_id'") | .master_user' $dir/.tmp_files/servers.json)

      # Configure server backups and enable local backups
      server_backup_data="{\"server_id\": \"$server_id\", \"backup_frequency\": \"${var.backup_frequency}\", \"backup_retention\": \"${var.backup_retention}\", \"local_backups\": ${var.local_backups}, \"backup_time\": \"${var.backup_time}\"}"
      curl -s -X POST \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $access_token" \
        -d "$server_backup_data" \
        'https://api.cloudways.com/api/v1/server/manage/backupSettings'

      create_SSHkey() {
        _note "Creating SSH key"
        ssh-keygen -b 2048 -t rsa -f $dir/.tmp_files/.ssh/bulkops -q -N ""
        pubkey=$(cat $dir/.tmp_files/.ssh/bulkops.pub)
      }
      create_SSHkey;
      _success "SSH key created"
      
      # Create JSON data to be used in SSH creation API request for servers
      create_keyFile () {
        echo "{" > $dir/.tmp_files/keyData.json
        echo "\"server_id\": \"$server_id\"," >> $dir/.tmp_files/keyData.json
        echo "\"ssh_key_name\": \"bulk_ops\"," >> $dir/.tmp_files/keyData.json
        echo "\"ssh_key\": \"$pubkey\"" >> $dir/.tmp_files/keyData.json
        echo "}" >> $dir/.tmp_files/keyData.json
      }

      create_keyFile;
      _note "Setting up SSH keys on the server"
      keyID=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H 'Accept: application/json' \
        -H 'Authorization: Bearer '$access_token'' \
        -d "@$dir/.tmp_files/keyData.json" 'https://api.cloudways.com/api/v1/ssh_key' | jq -r '.id')
        sleep 5;
      
      _success "SSH key setup completed."

      do_task() {
        rsync -e "ssh -i $dir/.tmp_files/.ssh/bulkops -o StrictHostKeyChecking=no" ${path.root}tf-sa-identity.json $sshUser@$srvIP:/home/master/.tf-sa-identity.json
        rsync -e "ssh -i $dir/.tmp_files/.ssh/bulkops -o StrictHostKeyChecking=no" \
      --rsync-path="mkdir -p /home/master/gcp_backups/ && rsync" \
      ${path.root}/backup_script.sh $sshUser@$srvIP:/home/master/gcp_backups/backup_script.sh

        # Connect to the new server and install gcloud
        ssh -i $dir/.tmp_files/.ssh/bulkops -o StrictHostKeyChecking=no $sshUser@$srvIP 'bash -s' <<'EOF'
        chmod 600 /home/master/.tf-sa-identity.json
        curl -s -O 'https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-455.0.0-linux-x86_64.tar.gz'
        tar -xf google-cloud-cli-455.0.0-linux-x86_64.tar.gz
        rm google-cloud-cli-455.0.0-linux-x86_64.tar.gz
        ./google-cloud-sdk/install.sh --rc-path ~/.bash_aliases --quiet
        source ~/.bashrc
        
        echo "45 15 * * * . /etc/profile && bash /home/master/gcp_backups/backup_script.sh >> /home/master/gcp_backups/cron.log 2>&1" | crontab -
        ###############################################################################################
EOF
        
        _note "Exiting server";
      }
      do_task;
      _note "Cleaning up files"
      rm -rf $dir/.tmp_files/
      _success "GCP offsite backups configured successfully."

    EOT
  }
}