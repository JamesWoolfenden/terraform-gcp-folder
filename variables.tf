variable "display_name" {
  type        = string
  description = "Display name of the folder"

  validation {
    condition     = length(trimspace(var.display_name)) > 0 && length(var.display_name) <= 30
    error_message = "var.display_name must be a non-empty string of at most 30 characters"
  }
}

variable "parent" {
  type        = string
  description = "Parent of the folder, either organizations/<id> or folders/<id>"

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "var.parent must be organizations/<id> or folders/<id>"
  }
}

variable "folder_viewers" {
  type        = list(string)
  description = "Principals granted roles/resourcemanager.folderViewer on the folder"

  validation {
    condition     = length(var.folder_viewers) > 0
    error_message = "var.folder_viewers must contain at least one principal"
  }

  validation {
    condition     = !anytrue([for m in var.folder_viewers : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.folder_viewers must not contain allUsers or allAuthenticatedUsers"
  }

  validation {
    condition     = !anytrue([for m in var.folder_viewers : can(regex("(compute@developer|appspot)[.]gserviceaccount[.]com$", m))])
    error_message = "var.folder_viewers must not contain default Compute or App Engine service accounts"
  }

  validation {
    condition     = !anytrue([for m in var.folder_viewers : can(regex("@(gmail|googlemail)[.]com$", m))])
    error_message = "var.folder_viewers must not contain personal Gmail accounts"
  }
}

variable "security_principal" {
  type        = string
  description = "Group or service account granted roles/iam.securityReviewer on the folder"

  validation {
    condition     = can(regex("^(group|serviceAccount):", var.security_principal))
    error_message = "var.security_principal must be a group or service account, such as group:security@example.com — roles/iam.securityReviewer reads every IAM and org policy in the folder, so it must not be bound to an individual user"
  }

  validation {
    condition     = !contains(["allUsers", "allAuthenticatedUsers"], var.security_principal)
    error_message = "var.security_principal must not be allUsers or allAuthenticatedUsers"
  }

  validation {
    condition     = !can(regex("(compute@developer|appspot)[.]gserviceaccount[.]com$", var.security_principal))
    error_message = "var.security_principal must not be a default Compute or App Engine service account"
  }

  validation {
    condition     = !can(regex("@(gmail|googlemail)[.]com$", var.security_principal))
    error_message = "var.security_principal must not be a personal Gmail account"
  }
}

variable "deletion_protection" {
  type        = bool
  description = "Whether the folder is protected from deletion"
  default     = true
}

variable "audit_log_types" {
  type        = list(string)
  description = "Audit log types enabled on the folder for allServices"
  default     = ["ADMIN_READ", "DATA_READ", "DATA_WRITE"]

  validation {
    condition     = length(setsubtract(var.audit_log_types, ["ADMIN_READ", "DATA_READ", "DATA_WRITE"])) == 0
    error_message = "var.audit_log_types must only contain ADMIN_READ, DATA_READ or DATA_WRITE"
  }

  validation {
    condition     = alltrue([for t in ["ADMIN_READ", "DATA_WRITE"] : contains(var.audit_log_types, t)])
    error_message = "var.audit_log_types must include ADMIN_READ and DATA_WRITE; only DATA_READ is optional"
  }
}

variable "require_shielded_vm" {
  type        = bool
  description = "Whether to enforce the compute.requireShieldedVm organization policy on the folder"
  default     = true
}
