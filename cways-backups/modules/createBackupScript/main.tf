resource "null_resource" "backupScript" {
  provisioner "local-exec" {
    command = <<-EOT
      cp ~/backup_script.sh "${path.root}/backup_script.sh"
      sed -i 's|gs://<enter-bucket-name>|gs://${var.cways-bucket-name}|g' "${path.root}/backup_script.sh"
    EOT
  }
}