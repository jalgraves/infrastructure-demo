# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

module "configs" {
  source    = "./modules/workspace_configs"
  workspace = terraform.workspace
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  configs    = module.configs.values
}
