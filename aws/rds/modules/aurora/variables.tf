variable "cluster_identifier" {
  description = "Name used for the Aurora cluster, subnet group, and instances."
  type        = string

  validation {
    condition     = length(var.cluster_identifier) >= 1 && length(var.cluster_identifier) <= 60
    error_message = "cluster_identifier must be between 1 and 60 characters so generated instance identifiers fit AWS limits."
  }
}

variable "engine" {
  description = "Aurora engine to use."
  type        = string

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "engine must be aurora-mysql or aurora-postgresql."
  }
}

variable "engine_version" {
  description = "Aurora engine version supported in the target region."
  type        = string
}

variable "master_username" {
  description = "Name of the cluster's master user."
  type        = string
}

variable "database_name" {
  description = "Optional name of the initial database."
  type        = string
  default     = null
}

variable "manage_master_user_password" {
  description = "Store and rotate the master password using AWS Secrets Manager."
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password, required when manage_master_user_password is false."
  type        = string
  sensitive   = true
  default     = null
}

variable "master_user_secret_kms_key_id" {
  description = "Optional KMS key ID for the Secrets Manager master-user secret."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group; use private subnets in at least two Availability Zones."
  type        = set(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for the DB subnet group."
  }
}

variable "vpc_security_group_ids" {
  description = "Security groups attached to the cluster. Inbound access should be limited to trusted clients."
  type        = set(string)

  validation {
    condition     = length(var.vpc_security_group_ids) > 0
    error_message = "At least one VPC security group ID is required."
  }
}

variable "port" {
  description = "Optional database port; defaults to the selected engine's default port."
  type        = number
  default     = null
}

variable "instance_class" {
  description = "DB instance class for every cluster instance."
  type        = string
}

variable "instance_count" {
  description = "Number of provisioned cluster instances, from one writer up to fifteen readers."
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 16 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count must be a whole number between 1 and 16."
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 1 and 35 days."
  }
}

variable "preferred_backup_window" {
  description = "Optional daily UTC backup window."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "Optional weekly UTC maintenance window."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Whether to encrypt the cluster storage."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS key ID for cluster storage encryption."
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication."
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to publish to CloudWatch Logs; supported values depend on the engine."
  type        = set(string)
  default     = []
}

variable "deletion_protection" {
  description = "Whether AWS should prevent deletion of the cluster."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when deleting the cluster."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Optional final snapshot identifier; defaults to <cluster_identifier>-final."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy cluster tags to snapshots."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether modifications requiring maintenance should be applied immediately."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether to allow automatic minor version upgrades for instances."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the cluster, subnet group, and instances."
  type        = map(string)
  default     = {}
}
