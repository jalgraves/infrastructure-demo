# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {
  type        = string
  description = <<EOT
    The Terraform workspace that is selected before Terraform runs.
    It is used to determine which values to use when creating the resources in the root `vpc/` directory.
  EOT
}

locals {
  workspaces = {
    api-euw1-route53 = local.api-euw1-route53
    api-use1-route53 = local.api-use1-route53
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `route53/` directory."
  value       = local.workspaces[var.workspace]
}
