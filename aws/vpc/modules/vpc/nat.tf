# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_eip" "this" {
  for_each = {
    for item in flatten([
      for az_name, az in var.availability_zones : [
        for subnet_name, subnet in az.subnets : {
          az_name     = az_name
          subnet_name = subnet_name
          cidr_block  = subnet.cidr_block
          route_table = subnet.route_table
        } if subnet.nat_gateway.create && var.route_tables[subnet.route_table].public
      ]
    ])
    : "${item.az_name}:${item.subnet_name}" => item
  }
  tags = {
    "Name" = data.aws_availability_zone.this[each.value.az_name].zone_id
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "this" {
  for_each = {
    for item in flatten([
      for az_name, az in var.availability_zones : [
        for subnet_name, subnet in az.subnets : {
          az_name     = az_name
          subnet_name = subnet_name
          cidr_block  = subnet.cidr_block
          route_table = subnet.route_table
        } if subnet.nat_gateway.create
      ]
    ])
    : item.subnet_name => item
  }
  allocation_id = aws_eip.this["${each.value.az_name}:${each.value.subnet_name}"].id
  subnet_id     = aws_subnet.this["${each.value.az_name}:${each.value.subnet_name}"].id

  tags = {
    Name = each.value.subnet_name
  }
}

resource "aws_route" "nat_gateway" {
  # Creates routes for NAT gateways in private route tables
  for_each = {
    for item in flatten([
      for route_table_name, route_table in var.route_tables : [
        for nat_gateway in route_table.nat_gateways : {
          route_table = route_table_name
          nat_gateway = nat_gateway
        }
      ]
    ])
    : "${item.route_table}:${item.nat_gateway}" => item
  }
  route_table_id         = aws_route_table.this[each.value.route_table].id
  nat_gateway_id         = aws_nat_gateway.this[each.value.nat_gateway].id
  destination_cidr_block = var.ipv4.destination_cidr_block
  depends_on             = [aws_route_table.this, aws_nat_gateway.this]
}
