# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  api-use1-ecr = {
    clusters = {
      services = {
        api-use1 = {
          port               = 3000,
          public             = true
          image              = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/api:0.1.72"
          healthcheck        = "/"
          certificate_domain = "${local.account_name}.aws.jalgraves.com"
          desired_count      = 1
          capacity_provider  = "FARGATE_SPOT"
          secrets = [
            {
              name      = "API_PASSWORD"
              valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_PASSWORD::"
            },
            {
              name      = "API_USERNAME"
              valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_USERNAME::"
            },
          ]
        }
      }
    }
  }
}
