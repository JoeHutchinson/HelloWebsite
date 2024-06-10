data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    tier = "public"
  }

}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    tier = "private"
  }
}