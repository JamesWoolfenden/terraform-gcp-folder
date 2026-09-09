# terraform-gcp-folder

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-folder/workflows/Verify/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-gcp-folder)
[![Latest Release](https://img.shields.io/github/release/terraform-gcp-folder.svg)](https://github.com/JamesWoolfenden/terraform-gcp-folder/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-folder.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-folder/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for a deletion-protected folder with least-privilege IAM,
data-access audit logging and an inherited shielded-VM organization policy.
Exercises holden's `google_folder_iam_binding`, `google_folder_iam_member`,
`google_folder_iam_audit_config` and folder-scoped `google_org_policy_policy`
policies.

## Usage

Add **module.folder.tf** to your code:-

```terraform
module "folder" {
  source         = "jameswoolfenden/folder/gcp"
  version        = "0.0.1"
  display_name   = "example-folder"
  parent         = "organizations/123456789012"
  folder_viewers = ["group:platform-engineers@example.com"]
  security_principal = "group:security@example.com"
}
```

`google_folder_iam_binding` is authoritative for `roles/resourcemanager.folderViewer`
on this folder — members added outside Terraform are removed on the next
apply. The security reviewer grant uses `google_folder_iam_member`, which is
additive, so it composes with grants made elsewhere.

`var.folder_viewers` and `var.security_principal` both reject `allUsers`,
`allAuthenticatedUsers`, the default Compute and App Engine service accounts,
and personal Gmail accounts.

`var.security_principal` additionally requires a `group:` or `serviceAccount:`
prefix. `roles/iam.securityReviewer` reads every IAM policy, org policy and
service-account key listing in the folder, so it is not a grant to bind to an
individual person: a group keeps the membership auditable and survives someone
changing teams, and a service account covers automated posture scanners.

> **Breaking change.** `var.security_group` was renamed to
> `var.security_principal`, and `user:` principals are no longer accepted.
> Callers must rename the argument; anyone passing a `user:` principal should
> move that person into a group and pass the group instead.

`var.audit_log_types` selects which audit log types are enabled for
`allServices`. `ADMIN_READ` and `DATA_WRITE` are mandatory — `DATA_WRITE` is
the tamper-evidence record of who changed what, and is low volume.
`DATA_READ` is the only optional type, and it is the expensive one: on a busy
folder it dominates Cloud Logging ingestion cost. Drop it if you must, but
know you are giving up data-plane read visibility.

Setting `var.require_shielded_vm = false` removes a security control — the
`compute.requireShieldedVm` organization policy is not created at all, and
nothing downstream will flag its absence. Only disable it for folders hosting
workloads that genuinely cannot run Shielded VM.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_folder.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder_iam_audit_config.all_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_audit_config) | resource |
| [google_folder_iam_binding.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_iam_member.security_reviewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_org_policy_policy.require_shielded_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audit_log_types"></a> [audit\_log\_types](#input\_audit\_log\_types) | Audit log types enabled on the folder for allServices | `list(string)` | <pre>[<br/>  "ADMIN_READ",<br/>  "DATA_READ",<br/>  "DATA_WRITE"<br/>]</pre> | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether the folder is protected from deletion | `bool` | `true` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name of the folder | `string` | n/a | yes |
| <a name="input_folder_viewers"></a> [folder\_viewers](#input\_folder\_viewers) | Principals granted roles/resourcemanager.folderViewer on the folder | `list(string)` | n/a | yes |
| <a name="input_parent"></a> [parent](#input\_parent) | Parent of the folder, either organizations/<id> or folders/<id> | `string` | n/a | yes |
| <a name="input_require_shielded_vm"></a> [require\_shielded\_vm](#input\_require\_shielded\_vm) | Whether to enforce the compute.requireShieldedVm organization policy on the folder | `bool` | `true` | no |
| <a name="input_security_principal"></a> [security\_principal](#input\_security\_principal) | Group or service account granted roles/iam.securityReviewer on the folder | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_folder_id"></a> [folder\_id](#output\_folder\_id) | Numeric ID of the folder |
| <a name="output_id"></a> [id](#output\_id) | ID of the folder |
| <a name="output_name"></a> [name](#output\_name) | Resource name of the folder, folders/<id> |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-gcp-folder/issues).

## Copyrights

Copyright © 2019-2026 [Jim Woolfenden](https://github.com/JamesWoolfenden)

## License

See [LICENSE](LICENSE) for full details.


<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "resourcemanager.folders.getIamPolicy",
    "resourcemanager.folders.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "resourcemanager.folders.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->
