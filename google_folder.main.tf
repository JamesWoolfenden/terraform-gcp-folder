resource "google_folder" "main" {
  display_name        = var.display_name
  parent              = var.parent
  deletion_protection = var.deletion_protection
}
