# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "aurora" {
  source = "../modules/aurora"

  for_each = {
    for db_name, db in local.configs.databases : db_name => db
  }

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
