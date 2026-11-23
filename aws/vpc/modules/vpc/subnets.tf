# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_subnet" "this" {
  for_each = {
    for item in flatten([
      for az_name, az in var.availability_zones : [
        for subnet_name, subnet in az.subnets : {
          az_name     = az_name
          subnet_name = subnet_name
          cidr_block  = subnet.cidr_block
          tier        = subnet.tier
          tags        = subnet.tags
        }
      ]
    ])
    : "${item.az_name}:${item.subnet_name}" => item
  }
  vpc_id                                         = aws_vpc.this.id
  availability_zone                              = each.value.az_name
  cidr_block                                     = each.value.cidr_block
  ipv6_cidr_block                                = local.subnet_ipv6_cidrs[each.key]
  assign_ipv6_address_on_creation                = var.ipv6.enabled ? var.ipv6.assign_ipv6_address_on_creation : false
  enable_dns64                                   = var.ipv6.enabled ? var.enable_dns64 : false
  enable_resource_name_dns_a_record_on_launch    = var.ipv4.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.ipv6.enabled ? var.ipv6.enable_resource_name_dns_aaaa_record_on_launch : false
  private_dns_hostname_type_on_launch            = var.private_dns_hostname_type_on_launch
  tags = merge(
    each.value.tags,
    {
      Name    = each.value.subnet_name
      Tier    = each.value.tier
      Network = aws_vpc.this.id
    }
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  # Creates an egress-only Internet gateway for a VPC to allow outbound-only IPv6 traffic
  count  = var.ipv6.enabled ? 1 : 0
  vpc_id = aws_vpc.this.id
}
