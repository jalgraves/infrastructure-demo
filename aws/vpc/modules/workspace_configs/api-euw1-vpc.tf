# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  api-euw1-vpc = {
    account_name = "api-euw1"
    region       = "eu-west-1"
    region_code  = "euw1"
    vpcs = {
      api-euw1-01 = {
        ipv4 = {
          cidr_block                                  = "10.1.0.0/16"
          destination_cidr_block                      = "0.0.0.0/0"
          enable_resource_name_dns_a_record_on_launch = true
        }
        ipv6 = {
          bits                                           = 8
          assign_ipv6_address_on_creation                = true
          destination_cidr_block                         = "64:ff9b::/96"
          enabled                                        = true
          enable_dns64                                   = true
          enable_resource_name_dns_aaaa_record_on_launch = true
        }
        route_tables = {
          api-euw1-01-private = {
            description  = "Private route table for api-euw1-01 VPC"
            public       = false
            nat_gateways = ["public-euw1-az1"]
          }
          api-euw1-01-public = {
            description  = "Public route table for api-euw1-01 VPC"
            public       = true
            nat_gateways = []
          }
        }
        availability_zones = {
          eu-west-1a = {
            subnets = {
              private-euw1-az1 = {
                cidr_block          = "10.1.224.0/21"
                tier                = "private"
                route_table         = "api-euw1-01-private"
                nat_gateway_enabled = true
                nat_gateway = {
                  create = false
                }
                tags = {}
              }
              public-euw1-az1 = {
                cidr_block          = "10.1.248.0/22"
                tier                = "public"
                route_table         = "api-euw1-01-public"
                nat_gateway_enabled = true
                nat_gateway = {
                  create = true
                }
                tags = {}
              }
            }
          }
          eu-west-1b = {
            subnets = {
              private-euw1-az2 = {
                cidr_block          = "10.1.232.0/21"
                tier                = "private"
                route_table         = "api-euw1-01-private"
                nat_gateway_enabled = true
                nat_gateway = {
                  create = false
                }
                tags = {}
              }
            }
          }
          eu-west-1c = {
            subnets = {
              private-euw1-az3 = {
                cidr_block          = "10.1.240.0/21"
                tier                = "private"
                route_table         = "api-euw1-01-private"
                nat_gateway_enabled = true
                nat_gateway         = { create = false }
                tags                = {}
              }
            }
          }

        }

        peering_connections = {
          accept = {
            data-cac1 = {
              connection_id = "pcx-01bd22a7ca1f77320"
              vpc_cidr      = "10.4.0.0/16"
              ipv6_cidr     = "2600:1f11:784:2b00::/56"
            }
            data-ape1 = {
              connection_id = "pcx-020323229f41ce8e6"
              vpc_cidr      = "10.3.0.0/16"
              ipv6_cidr     = "2406:da1e:469:2300::/56"
            }
            data-euc1 = {
              connection_id = "pcx-0bb2672fe7924ce03"
              vpc_cidr      = "10.5.0.0/16"
              ipv6_cidr     = "2a05:d014:b42:2700::/56"
            }
            data-use2 = {
              connection_id = "pcx-03007a1941755fbfa"
              vpc_cidr      = "10.6.0.0/16"
              ipv6_cidr     = "2600:1f16:db4:ff00::/56"
            }
          }
          request = {}
        }
        security_groups = {
          internal = {
            description = "Allow private subnet traffic within VPC. Created via Terraform workspace ${terraform.workspace}"
            ingress = [
              {
                description      = "Allow all traffic within the private CIDR. Created via Terraform workspace ${terraform.workspace}"
                from_port        = 0
                to_port          = 0
                protocol         = "tcp"
                cidr_blocks      = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.0/16", "10.6.0.0/16"]
                ipv6_cidr_blocks = null
                #ipv6_cidr_blocks = ["::/0"]
              }
            ]
            egress = [
              {
                description      = "Allow egress to DBs. Created via Terraform workspace ${terraform.workspace}"
                from_port        = 5432
                to_port          = 5432
                protocol         = "tcp"
                cidr_blocks      = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.0/16", "10.6.0.0/16"]
                ipv6_cidr_blocks = ["::/0"]
              }
            ]
            tags = {}
          }
        }
      }
    }
    vpns = {}
  }
}
