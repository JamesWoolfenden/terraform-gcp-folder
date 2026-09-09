resource "google_folder_iam_audit_config" "all_services" {
  folder  = google_folder.main.name
  service = "allServices"

  dynamic "audit_log_config" {
    for_each = toset(var.audit_log_types)

    content {
      log_type = audit_log_config.value
    }
  }
}
