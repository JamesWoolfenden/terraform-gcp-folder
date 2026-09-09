resource "google_folder_iam_member" "security_reviewer" {
  folder = google_folder.main.name
  role   = "roles/iam.securityReviewer"
  member = var.security_principal
}
