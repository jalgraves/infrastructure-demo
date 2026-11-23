# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  default_security_groups = {
    internal = {
      description = "Allow private subnet traffic within VPC. Created via Terraform workspace ${terraform.workspace}"
      ingress = [
        {
          description      = "Allow all traffic within the private CIDR. Created via Terraform workspace ${terraform.workspace}"
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["10.0.0.0/8", "172.0.0.0/8"]
          ipv6_cidr_blocks = null
          #ipv6_cidr_blocks = ["::/0"]
        }
      ]
      egress = [
        {
          description      = "Allow all egress. Created via Terraform workspace ${terraform.workspace}"
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
      ]
      tags = {}
    }
  }
}
