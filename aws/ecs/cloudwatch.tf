# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

resource "aws_cloudwatch_log_group" "ecs" {
  for_each = {
    for item in flatten([
      for cluster_name, cluster in local.configs.clusters : [
        for service_name, service in cluster.services : {
          cluster_name = cluster_name
          service_name = service_name
        }
      ]
    ])
    : "${item.cluster_name}:${item.service_name}" => item
  }

  name              = "/ecs/${each.value.service_name}"
  retention_in_days = 7

  tags = {
    Name = "/ecs/${each.value.service_name}"
  }
}
