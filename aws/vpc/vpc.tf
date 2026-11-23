# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "vpc" {
  # VPC created with new module that can support IPv6
  # Below is an example of how to use the module with development branch:
  # source = "git::https://github.com/jalgraves/terraform-aws-vpc?ref=aa275df3349afbb0fa8c1d389f5adc910f9045dd"
  # source  = "app.terraform.io/hqo/vpc/aws"
  # version = "0.2.3"
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
