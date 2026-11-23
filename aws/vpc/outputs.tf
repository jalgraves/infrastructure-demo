# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "vpcs" {
  value = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => {
      cidr_block      = module.vpc[vpc_name].vpc.cidr_block
      ipv6_cidr_block = module.vpc[vpc_name].vpc.ipv6_cidr_block
      id              = module.vpc[vpc_name].vpc.id
      subnets         = module.vpc[vpc_name].subnets
      route_tables    = module.vpc[vpc_name].route_tables
    }
  }
}

output "peering_connections" {
  value = aws_vpc_peering_connection.this
}
