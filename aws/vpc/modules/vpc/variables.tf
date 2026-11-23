# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "assign_generated_ipv6_cidr_block" {
  type    = bool
  default = true
}

variable "route_tables" {
  description = <<EOF
  The route tables to be created within the VP. If creating a public subnet with a
  NAT gateway, ensure the name of the subnet is included in nat_gateways list.
  EOF
  type = map(object({
    description  = string
    public       = bool
    nat_gateways = list(string)
  }))
  default = {}
}

variable "availability_zones" {
  description = <<EOF
  The availability zones (azs) within a region that will contain the subnets for the VPC.
  EOF
  type = map(object({
    subnets = map(object({
      cidr_block  = string
      tier        = string
      route_table = string
      nat_gateway = object({
        create = bool
      })
      tags = map(string)
    }))
  }))
  default = {}
}

variable "internet_gateway_enabled" {
  description = "Enables the creation of an Internet Gateway for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns64" {
  description = "Enables dns64 if IPv6 is being used"
  default     = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "ipv4" {
  description = "Configs for supporting IPv4 in the VPC"
  type = object({
    cidr_block                                  = string
    destination_cidr_block                      = string
    enable_resource_name_dns_a_record_on_launch = bool
  })
  default = null
}

variable "ipv6" {
  description = "Configs for supporting IPv6 in the VPC"
  type = object({
    bits                                           = number
    assign_ipv6_address_on_creation                = bool
    destination_cidr_block                         = string
    enabled                                        = bool
    enable_dns64                                   = bool
    enable_resource_name_dns_aaaa_record_on_launch = bool
  })
  default = null
}

variable "private_dns_hostname_type_on_launch" {
  type    = string
  default = "ip-name"
}

variable "region" {
  type        = string
  description = "The region the VPC is being created in"
}
variable "region_code" {
  type        = string
  description = "AWS abbreviation for the region the VPC is being created in"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}
