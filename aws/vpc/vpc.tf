# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "vpc" {
  # Creates a VPC with the specified configuration, including IPv4 and IPv6 settings,
  # availability zones, subnets, and route tables
  source = "./modules/vpc"


  for_each = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => vpc
  }

  vpc_name                         = each.key
  assign_generated_ipv6_cidr_block = each.value.ipv6.enabled
  availability_zones               = each.value.availability_zones
  ipv4                             = each.value.ipv4
  ipv6                             = each.value.ipv6
  region                           = local.configs.region
  region_code                      = local.configs.region_code
  route_tables                     = each.value.route_tables
}
