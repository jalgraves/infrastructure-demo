# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_security_group" "this" {
  for_each = {
    for item in flatten([
      for vpc_name, vpc in local.configs.vpcs : [
        for security_group_name, security_group in vpc.security_groups : {
          vpc_name   = vpc_name
          group_name = "${vpc_name}-${security_group_name}"
          group_id   = security_group_name
          group      = security_group
        }
      ]
    ])
    : "${item.group_id}-${item.vpc_name}" => item
  }
  name        = each.value.group_name
  description = each.value.group.description
  vpc_id      = module.vpc[each.value.vpc_name].vpc.id

  dynamic "ingress" {
    for_each = each.value.group.ingress
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = each.value.group.egress
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge({ Name = each.value.group_name },
    each.value.group.tags
  )
}
