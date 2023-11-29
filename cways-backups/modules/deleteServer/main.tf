resource "null_resource" "deleteServer" {
  triggers = {
    email     = var.cloudways-email
    api_key_path = var.cloudways_apikey_file_path
    ServerID  = var.serverID
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      echo Email: ${self.triggers.email}
      api_key=$(cat ${self.triggers.api_key_path})
      echo key: $api_key
      echo ServerID: ${self.triggers.ServerID}
    EOT
  }
}
