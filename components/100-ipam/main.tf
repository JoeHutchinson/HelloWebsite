resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = var.region
  }
  cascade = true
}

resource "aws_vpc_ipam_pool" "this" {
  description                       = "IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.private_default_scope_id
  locale                            = var.region
  allocation_default_netmask_length = 28

  cascade = true
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = "10.0.0.0/8"
}