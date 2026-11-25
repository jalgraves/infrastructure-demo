# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  api-euw1-route53 = {
    healthchecks = {
      api = {
        fqdn              = "api-euw1.aws.jalgraves.com"
        port              = 443
        type              = "HTTPS"
        resource_path     = "/aws/healthcheck"
        failure_threshold = 3
        request_interval  = 30
        regions = [
          "eu-west-1",
          "us-east-1"
        ]
      }
    }
  }
}
