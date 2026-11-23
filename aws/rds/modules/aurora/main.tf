resource "aws_db_subnet_group" "this" {
  name        = "${var.cluster_identifier}-subnets"
  description = "Subnets for Aurora cluster ${var.cluster_identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-subnets"
  })
}

resource "aws_rds_cluster" "this" {
  cluster_identifier                  = var.cluster_identifier
  engine                              = var.engine
  engine_version                      = var.engine_version
  database_name                       = var.database_name
  master_username                     = var.master_username
  manage_master_user_password         = var.manage_master_user_password
  master_password                     = var.manage_master_user_password ? null : var.master_password
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = var.vpc_security_group_ids
  port                                = var.port
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.cluster_identifier}-final")
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  apply_immediately                   = var.apply_immediately

  tags = merge(var.tags, {
    Name = var.cluster_identifier
  })

  lifecycle {
    precondition {
      condition     = var.manage_master_user_password ? var.master_password == null : var.master_password != null
      error_message = "Set master_password only when manage_master_user_password is false, and provide it when management is disabled."
    }
  }
}

resource "aws_rds_cluster_instance" "this" {
  for_each = {
    for index in range(var.instance_count) : tostring(index) => index
  }

  identifier                 = "${var.cluster_identifier}-${each.key}"
  cluster_identifier         = aws_rds_cluster.this.id
  instance_class             = var.instance_class
  engine                     = var.engine
  engine_version             = var.engine_version
  publicly_accessible        = false
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  promotion_tier             = each.value
  apply_immediately          = var.apply_immediately

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-${each.key}"
  })
}
