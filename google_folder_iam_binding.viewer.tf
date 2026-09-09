resource "google_folder_iam_binding" "viewer" {
  folder  = google_folder.main.name
  role    = "roles/resourcemanager.folderViewer"
  members = var.folder_viewers
}
