# Aurora Cluster Module

Creates a provisioned Amazon Aurora MySQL or Aurora PostgreSQL cluster, its DB subnet group, and one or more cluster instances. Supply private subnet IDs from at least two Availability Zones and security groups whose ingress is restricted to trusted clients.

The module enables storage encryption, managed master-password storage in Secrets Manager, deletion protection, seven-day automated backups, and final snapshots by default. It does not create VPCs or security groups and does not configure Aurora Serverless or Global Database.

```hcl
module "aurora" {
  source = "../modules/aurora"

  cluster_identifier     = "app-prod"
  engine                 = "aurora-postgresql"
  engine_version         = "<supported-version>"
  database_name          = "app"
  master_username        = "app_admin"
  instance_class         = "db.r7g.large"
  instance_count         = 2
  subnet_ids             = ["subnet-0123456789abcdef0", "subnet-0abcdef0123456789"]
  vpc_security_group_ids = ["sg-0123456789abcdef0"]

  tags = {
    Environment = "production"
  }
}
```

Engine versions and instance classes must be supported by Aurora in the selected region. Set `skip_final_snapshot = true` only when intentionally discarding the final snapshot. Override `final_snapshot_identifier` when re-creating a cluster whose default final snapshot name already exists.

The master password is managed by AWS Secrets Manager by default. Set `manage_master_user_password = false` and provide the sensitive `master_password` input only when external password management is required.

The writer endpoint, reader endpoint, cluster metadata, managed secret ARN, and instance identifiers are exposed as module outputs.
