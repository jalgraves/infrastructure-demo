# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  account_id   = data.aws_caller_identity.current.account_id
  bucket_name  = var.remote_state_bucket != null ? var.remote_state_bucket : "${local.account_name}-remote-state"
  account_role = split("-", var.workspace)[0]
  region_code  = split("-", var.workspace)[1]
  regions = {
    use1 = "us-east-1"
    euw1 = "eu-west-1"
  }
  region       = local.regions[local.region_code]
  account_name = "${local.account_role}-${local.region_code}"
  workspaces = {
    api-use1-ecr = local.api-use1-ecr
    api-euw1-ecr = local.api-euw1-ecr
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `vpc/` directory."
  value       = local.workspaces[var.workspace]
}
