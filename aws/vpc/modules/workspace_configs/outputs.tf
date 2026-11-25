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
    api-euw1-vpc  = local.api-euw1-vpc
    api-use1-vpc  = local.api-use1-vpc
    data-ape1-vpc = local.data-ape1-vpc
    data-cac1-vpc = local.data-cac1-vpc
    data-euc1-vpc = local.data-euc1-vpc
    data-use2-vpc = local.data-use2-vpc
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `vpc/` directory."
  value       = local.workspaces[var.workspace]
}
