# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  organizational_units = {
    api   = {}
    audit = {}
    data  = {}
  }
  accounts = {
    api-euw1 = {
      email               = var.api_euw1_email
      organizational_unit = "api"
      allowed_regions     = ["eu-west-1"]
    }
    api-use1 = {
      email               = var.api_use1_email
      organizational_unit = "api"
      allowed_regions     = ["us-east-1"]
    }
    data-ape1 = {
      email               = var.data_ape1_email
      organizational_unit = "data"
      allowed_regions     = ["ap-east-1"]
    }
    data-cac1 = {
      email               = var.data_cac1_email
      organizational_unit = "data"
      allowed_regions     = ["ca-central-1"]
    }
    data-euc1 = {
      email               = var.data_euc1_email
      organizational_unit = "data"
      allowed_regions     = ["eu-central-1"]
    }
    data-use2 = {
      email               = var.data_use2_email
      organizational_unit = "data"
      allowed_regions     = ["us-east-2"]
    }
  }
}
