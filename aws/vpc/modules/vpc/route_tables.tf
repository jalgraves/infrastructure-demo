# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_internet_gateway" "this" {
  count  = var.internet_gateway_enabled ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_route_table" "this" {
  # https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
  # Creates route tables for the VPC based on the provided configuration
  # Each route table is associated with a specific subnet and defines the routing rules for that subnet
  # This includes both public and private route tables, depending on the subnet's configuration
  # Public route tables typically have a route to the Internet Gateway, while private route tables may have routes to NAT gateways
  # This ensures that traffic from different subnets is routed appropriately based on the subnet's configuration
  # It helps maintain network isolation and security by controlling the flow of traffic within the VPC
  for_each = {
    for route_table_name, route_table in var.route_tables : route_table_name => route_table
  }
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = each.key
    Network = aws_vpc.this.id
  }
}

resource "aws_route" "public_internet" {
  # Create a routing table entry (a route) for public route tables to Internet Gateway
  for_each = {
    for route_table_name, route_table in var.route_tables : route_table_name => route_table
    if route_table.public && var.internet_gateway_enabled
  }
  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "ipv6" {
  for_each = {
    for route_table_name, route_table in var.route_tables : route_table_name => route_table
    if !route_table.public && var.ipv6.enabled
  }
  route_table_id              = aws_route_table.this[each.key].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this[0].id
}

resource "aws_route_table_association" "this" {
  for_each = {
    for item in flatten([
      for az_name, az in var.availability_zones : [
        for subnet_name, subnet in az.subnets : {
          az_name     = az_name
          subnet_name = subnet_name
          cidr_block  = subnet.cidr_block
          route_table = subnet.route_table
        }
      ]
    ])
    : "${item.az_name}:${item.subnet_name}" => item
  }
  subnet_id      = aws_subnet.this["${each.value.az_name}:${each.value.subnet_name}"].id
  route_table_id = aws_route_table.this[each.value.route_table].id
}
