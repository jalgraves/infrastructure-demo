# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  data-cac1-rds = {
    region = "ca-central-1"
    databases = {
      psql = {
        admin_user                      = "db_admin"
        allowed_cidr_blocks             = []
        auto_minor_version_upgrade      = false
        backtrack_window                = null
        cluster_family                  = "aurora-postgresql12"
        cluster_identifier              = "data-cac1"
        cluster_parameters              = []
        cluster_size                    = 1
        deletion_protection             = false
        enable_global_write_forwarding  = false
        enabled                         = true
        enabled_cloudwatch_logs_exports = ["postgresql"]
        engine                          = "aurora-postgresql"
        engine_lifecycle_support        = "open-source-rds-extended-support"
        engine_version                  = "12.22"
        instance_class                  = "db.t4g.large"
        monitoring_interval             = 0
        performance_insights_enabled    = true
        port                            = 5432
        retention_period                = 7
        serverless                      = { enabled = false }
        storage_encrypted               = true
        subnet_ids                      = data.terraform_remote_state.vpc.outputs.vpcs["data-cac1-01"].subnet_ids
        vpc_security_group_ids          = data.terraform_remote_state.vpc.outputs.vpcs["data-cac1-01"].vpc_security_group_ids
        kms_key = {
          is_primary = false
          name       = null
        }
        global = {
          enabled                        = false
          force_destroy                  = true
          primary                        = false
          enable_global_write_forwarding = false
          cluster_identifier             = null
          kms_key_arn                    = null
          source_db_cluster_arn          = null
        }
      }
    }
  }
}
