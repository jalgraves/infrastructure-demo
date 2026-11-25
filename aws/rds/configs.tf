# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "configs" {
  source              = "./modules/workspace_configs"
  workspace           = terraform.workspace
  remote_state_bucket = var.remote_state_bucket
}

locals {
  configs = module.configs.values
}
