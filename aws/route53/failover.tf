# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_route53_record" "api_primary" {
  zone_id        = var.hosted_zone_id
  name           = "api.internal.example.com"
  type           = "A"
  set_identifier = "api-use1"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.api_use1.id

  alias {
    name                   = var.use1_endpoint_dns_name
    zone_id                = var.use1_endpoint_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_secondary" {
  zone_id        = var.hosted_zone_id
  name           = "api.internal.example.com"
  type           = "A"
  set_identifier = "api-euw1"

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = aws_route53_health_check.api_euw1.id

  alias {
    name                   = var.euw1_endpoint_dns_name
    zone_id                = var.euw1_endpoint_zone_id
    evaluate_target_health = true
  }
}
