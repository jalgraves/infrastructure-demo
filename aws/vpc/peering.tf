# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_vpc_peering_connection" "this" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for peer_connection_name, peer_connection in vpc.peering_connections.request : {
          peer_connection_name = peer_connection_name
          peer_id              = peer_connection.vpc_id
          peer_owner_id        = peer_connection.peer_owner_id
          vpc_name             = vpc_name
          region               = peer_connection.region
        }
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}" => item
  }
  peer_vpc_id   = each.value.peer_id
  peer_owner_id = each.value.peer_owner_id
  vpc_id        = module.vpc[each.value.vpc_name].vpc.id
  peer_region   = each.value.region
  tags = {
    Name = "${each.value.vpc_name}-${each.value.peer_connection_name}"
  }
  depends_on = [module.vpc]
}

resource "aws_vpc_peering_connection_accepter" "this" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for peer_connection_name, peer_connection in vpc.peering_connections.accept : {
          peer_connection_name = peer_connection_name
          connection_id        = peer_connection.connection_id
          vpc_cidr             = peer_connection.vpc_cidr
          vpc_name             = vpc_name
        }
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}" => item
  }
  vpc_peering_connection_id = each.value.connection_id
  auto_accept               = true
  tags = {
    Name = "${each.value.vpc_name}-${each.value.peer_connection_name}"
  }
  depends_on = [module.vpc]
}

resource "aws_route" "peering_request" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for k, table_id in toset(nonsensitive(module.vpc[vpc_name].route_table_ids)) : [
          for peer_connection_name, peer_connection in vpc.peering_connections.request : {
            peer_connection_name = peer_connection_name
            vpc_name             = vpc_name
            table_id             = table_id
            connection_id        = aws_vpc_peering_connection.this["${vpc_name}:${peer_connection_name}"].id
            vpc_cidr             = peer_connection.vpc_cidr
          } if peer_connection.enabled
        ]
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}:${item.table_id}:${item.connection_id}" => item
  }
  route_table_id            = each.value.table_id
  destination_cidr_block    = each.value.vpc_cidr
  vpc_peering_connection_id = each.value.connection_id
  depends_on                = [module.vpc, aws_vpc_peering_connection.this]
}

resource "aws_route" "peering_accept" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for k, table_id in toset(nonsensitive(module.vpc[vpc_name].route_table_ids)) : [
          for peer_connection_name, peer_connection in vpc.peering_connections.accept : {
            peer_connection_name = peer_connection_name
            vpc_name             = vpc_name
            table_id             = table_id
            connection_id        = peer_connection.connection_id
            vpc_cidr             = peer_connection.vpc_cidr
          }
        ]
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}:${item.table_id}:${item.connection_id}" => item
  }
  route_table_id            = each.value.table_id
  destination_cidr_block    = each.value.vpc_cidr
  vpc_peering_connection_id = each.value.connection_id
  depends_on                = [module.vpc, aws_vpc_peering_connection_accepter.this]
}

resource "aws_route" "peering_request_ipv6" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for k, table_id in toset(nonsensitive(module.vpc[vpc_name].route_table_ids)) : [
          for peer_connection_name, peer_connection in vpc.peering_connections.request : {
            peer_connection_name = peer_connection_name
            vpc_name             = vpc_name
            table_id             = table_id
            connection_id        = aws_vpc_peering_connection.this["${vpc_name}:${peer_connection_name}"].id
            ipv6_cidr            = peer_connection.ipv6_cidr
          } if peer_connection.enabled && peer_connection.ipv6_cidr != null
        ]
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}:${item.table_id}:${item.connection_id}" => item
  }
  route_table_id              = each.value.table_id
  destination_ipv6_cidr_block = each.value.ipv6_cidr
  vpc_peering_connection_id   = each.value.connection_id
  depends_on                  = [module.vpc, aws_vpc_peering_connection.this]
}

resource "aws_route" "peering_accept_ipv6" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for k, table_id in toset(nonsensitive(module.vpc[vpc_name].route_table_ids)) : [
          for peer_connection_name, peer_connection in vpc.peering_connections.accept : {
            peer_connection_name = peer_connection_name
            vpc_name             = vpc_name
            table_id             = table_id
            connection_id        = peer_connection.connection_id
            ipv6_cidr            = peer_connection.ipv6_cidr
          } if peer_connection.ipv6_cidr != null
        ]
      ]
    ])
    : "${item.vpc_name}:${item.peer_connection_name}:${item.table_id}:${item.connection_id}" => item
  }
  route_table_id              = each.value.table_id
  destination_ipv6_cidr_block = each.value.ipv6_cidr
  vpc_peering_connection_id   = each.value.connection_id
  depends_on                  = [module.vpc, aws_vpc_peering_connection_accepter.this]
}
