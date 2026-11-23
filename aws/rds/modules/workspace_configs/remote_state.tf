# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "terraform_remote_state" "vpc" {
  # These are resources that have previously been created in the aws/vpc directory
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "env:/${local.account_name}-vpc/vpc/${local.account_name}.tfstate"
    region = local.region
  }
}
