# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  data-cac1-rds = {
    region = "ca-central-1"
    databases = {
      psql = {
        # admin_user is the key that points to actual db username for admin
        admin_password_required         = true
        admin_user                      = "hqos_postgresql_db_root_user"
        allowed_cidr_blocks             = []
        auto_minor_version_upgrade      = false
        backtrack_window                = null
        cluster_family                  = "aurora-postgresql12"
        cluster_identifier              = "preprod-use1-psql"
        cluster_parameters              = []
        cluster_size                    = 1
        deletion_protection             = false
        dns                             = { labels = ["psql"] }
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
        secrets_manager_password_key    = "psql_db_root_pass"
        serverless                      = { enabled = false }
        storage_encrypted               = true
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
