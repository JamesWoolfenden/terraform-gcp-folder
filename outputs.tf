output "id" {
  value       = google_folder.main.id
  description = "ID of the folder"
}

output "name" {
  value       = google_folder.main.name
  description = "Resource name of the folder, folders/FOLDER_ID"
}

output "folder_id" {
  value       = google_folder.main.folder_id
  description = "Numeric ID of the folder"
}
