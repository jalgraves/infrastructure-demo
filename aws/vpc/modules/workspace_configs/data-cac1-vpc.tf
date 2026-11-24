# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# VPC configurations specific to the data-cac1 environment are defined here.

locals {
  data-cac1-vpc = {
    account_name = "data-cac1"
    region       = "ca-central-1"
    region_code  = "cac1"
    vpcs = {
      # The key for each VPC will be used as the VPC name
      data-cac1-01 = {
        ipv4 = {
          cidr_block                                  = "10.4.0.0/16"
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
          data-cac1-01-private = {
            description  = "Private route table for data-cac1-01 VPC"
            public       = false
            nat_gateways = []
          }
        }
        availability_zones = {
          ca-central-1a = {
            subnets = {
              data-cac1-az1-private = {
                cidr_block  = "10.4.253.0/24"
                tier        = "data"
                route_table = "data-cac1-01-private"
                nat_gateway = { create = false }
                tags        = {}
              }
            }
          }
          ca-central-1b = {
            subnets = {
              data-cac1-az2-private = {
                cidr_block  = "10.4.254.0/24"
                tier        = "data"
                route_table = "data-cac1-01-private"
                nat_gateway = { create = false }
                tags        = {}
              }
            }
          }
          ca-central-1d = {
            subnets = {
              data-cac1-az4-private = {
                cidr_block  = "10.4.255.0/24"
                tier        = "data"
                route_table = "data-cac1-01-private"
                nat_gateway = { create = false }
                tags        = {}
              }
            }
          }

        }
        peering_connections = {
          accept = {}
          request = {
            # Peering requests should be set to enabled = false until the connection is accepted
            # by the peer VPC owner.
            api-use1 = {
              vpc_id        = "vpc-0837ae5e9ed715deb"
              peer_owner_id = "433464105905"
              region        = "us-east-1"
              vpc_cidr      = "10.2.0.0/16"
              ipv6_cidr     = "2600:1f18:6dea:9000::/56"
              enabled       = true
            }
            api-euw1 = {
              vpc_id        = "vpc-05448098fddcd059b"
              peer_owner_id = "672767113648"
              region        = "eu-west-1"
              vpc_cidr      = "10.1.0.0/16"
              ipv6_cidr     = "2a05:d018:120c:4300::/56"
              enabled       = true
            }
          }
        }
        security_groups = {
          internal = {
            description = "Allow private subnet traffic within VPC. Created via Terraform workspace ${terraform.workspace}"
            ingress = [
              {
                description      = "Allow API VPCs traffic. Created via Terraform workspace ${terraform.workspace}"
                from_port        = 5432
                to_port          = 5432
                protocol         = "tcp"
                cidr_blocks      = ["10.1.0.0/16", "10.2.0.0/16"]
                ipv6_cidr_blocks = null
                #ipv6_cidr_blocks = ["::/0"]
              }
            ]
            egress = []
            tags   = {}
          }
        }
      }
    }
    vpns = {}
  }
}
