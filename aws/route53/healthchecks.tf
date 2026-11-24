# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

data "aws_lb" "public" {
  for_each = {
    for record_name, record in local.configs.dns.global : record_name => record
  }
  name = each.value.alb_name
}

resource "aws_route53_health_check" "this" {
  for_each = {
    for healthcheck_name, healthcheck in local.configs.healthchecks : healthcheck_name => healthcheck
  }
  fqdn              = each.value.fqdn
  port              = each.value.port
  type              = each.value.type
  resource_path     = each.value.resource_path
  failure_threshold = each.value.failure_threshold
  request_interval  = each.value.request_interval
  regions           = each.value.regions
  tags = {
    Name = "${local.configs.region_code}-${each.key}"
  }
}

resource "aws_route53_record" "global" {
  for_each = {
    for record_name, record in local.configs.dns.global : record_name => record
  }
  zone_id         = try(aws_route53_zone.this[each.value.zone].zone_id, each.value.zone_id)
  name            = each.key
  type            = each.value.type
  health_check_id = aws_route53_health_check.this[each.value.healthcheck_id].id
  set_identifier  = each.value.set_identifier

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation.continent != null ? [1] : []
    content {
      continent = each.value.geolocation.continent
    }
  }
  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation.country != null ? [1] : []
    content {
      country = each.value.geolocation.country
      #subdivision = each.value.geolocation.subdivision
    }
  }
  alias {
    name                   = data.aws_lb.public[each.key].dns_name
    zone_id                = data.aws_lb.public[each.key].zone_id
    evaluate_target_health = true
  }
}

output "healthchecks" {
  value = {
    for_each = {
      for healthcheck_name, healthcheck in local.configs.healthchecks : healthcheck_name => {
        id = aws_route53_health_check.this[healthcheck_name].id
      }
    }
  }
}
