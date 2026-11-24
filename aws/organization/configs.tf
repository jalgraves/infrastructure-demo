# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Configuration for resources that will be managed within the AWS organization

locals {
  organizational_units = {
    # Groups of AWS accounts, used for applying the same controls to multiple accounts
    # Each key represents a single organizational unit
    # The value is an empty object, as the organizational unit itself does not have additional configuration in this context
    api   = {}
    audit = {}
    data  = {}
  }
  accounts = {
    # Member accounts within the organization
    # Each key represents a single AWS account within the organization
    log = {
      # Audit account for logging purposes
      email               = var.log_email
      organizational_unit = "audit"
      allowed_regions     = ["us-east-1"]
    }
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
