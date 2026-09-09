variable "parent" {
  type        = string
  description = "Parent of the folder"
  default     = "organizations/123456789012"

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "var.parent must be organizations/<id> or folders/<id>"
  }
}
