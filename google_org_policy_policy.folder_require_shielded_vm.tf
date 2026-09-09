resource "google_org_policy_policy" "require_shielded_vm" {
  count = var.require_shielded_vm ? 1 : 0

  name   = "${google_folder.main.name}/policies/compute.requireShieldedVm"
  parent = google_folder.main.name

  spec {
    inherit_from_parent = true

    rules {
      enforce = "TRUE"
    }
  }
}
