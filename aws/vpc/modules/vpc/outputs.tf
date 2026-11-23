# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "vpc" {
  value = {
    cidr_block          = aws_vpc.this.cidr_block
    ipv6_cidr_block     = try(aws_vpc.this.ipv6_cidr_block, null)
    id                  = aws_vpc.this.id
    nat_ips             = [for nat_name, nat in aws_nat_gateway.this : nat.allocation_id]
    ipv6_association_id = aws_vpc.this.ipv6_association_id
    ipv6_cidr_block     = aws_vpc.this.ipv6_cidr_block
  }
}

output "subnets" {
  value = aws_subnet.this
}

output "route_tables" {
  value = aws_route_table.this
}

output "route_table_ids" {
  value = [for route_table_name, route_table in aws_route_table.this : route_table.id]
}
