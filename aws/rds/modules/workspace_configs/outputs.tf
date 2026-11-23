# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {
  type        = string
  description = <<EOT
    The Terraform workspace that is selected before Terraform runs.
    It is used to determine which values to use when creating the resources in the root `rds/` directory.
  EOT
}

variable "remote_state_bucket" {
  type        = string
  description = "The name of the S3 bucket where the remote state is stored."
  default     = null
}

locals {
  bucket_name  = var.remote_state_bucket != null ? var.remote_state_bucket : "${local.account_name}-remote-state"
  account_role = split("-", var.workspace)[0]
  region_code  = split("-", var.workspace)[1]
  account_name = "${local.account_role}-${local.region_code}"
  regions = {
    "ape1" = "ap-east-1"
    "cac1" = "ca-central-"
    "euc1" = "eu-central-1"
    "use2" = "us-east-2"
  }
  region = local.regions[local.region_code]
  workspaces = {
    data-ape1-rds = local.data-ape1-rds
    data-cac1-rds = local.data-cac1-rds
    data-euc1-rds = local.data-euc1-rds
    data-use2-rds = local.data-use2-rds
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `rds/` directory."
  value       = local.workspaces[var.workspace]
}
