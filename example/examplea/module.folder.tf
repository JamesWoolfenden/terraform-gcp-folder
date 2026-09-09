# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for expansion
module "folder" {
  source             = "../../"
  display_name       = "example-folder"
  parent             = var.parent
  folder_viewers     = ["group:platform-engineers@example.com"]
  security_principal = "group:security@example.com"
}
