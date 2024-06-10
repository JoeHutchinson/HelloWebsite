locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr          = "10.1.0.0/16"
  azs               = slice(data.aws_availability_zones.available.names, 0, 3)
  ##preview_partition = cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.this.cidr, 2, 2, 2)
}

data "aws_availability_zones" "available" {}

## IPAM work in progress...
# module "vpc_ipam_set_netmask" {
#   source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.8.1"

#   name = "${local.name}-set-netmask"

#   use_ipam_pool       = true
#   ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.this.id
#   ipv4_netmask_length = 16
#   azs                 = local.azs

#   private_subnets = cidrsubnets(local.preview_partition[0], 2, 2, 2)
#   public_subnets  = cidrsubnets(local.preview_partition[1], 2, 2, 2)
# }

# module "vpc_ipam_set_cidr" {
#   source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.8.1"

#   name = "${local.name}-set-cidr"

#   use_ipam_pool     = true
#   ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.this.id
#   cidr              = local.vpc_cidr
#   azs               = local.azs

#   private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]   # why not use cidrsubnets?
#   public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
# }

# data "aws_vpc_ipam_pool" "this" {
#   filter {
#     name   = "description"
#     values = ["IPv4 pool"]
#   }

#   filter {
#     name   = "address-family"
#     values = ["ipv4"]
#   }
# }

# data "aws_vpc_ipam_preview_next_cidr" "this" {
#   ipam_pool_id   = data.aws_vpc_ipam_pool.this.id
#   netmask_length = 28
# }

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.8.1"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  private_subnet_tags = {
    tier = "private"
  }

  public_subnet_tags = {
    tier = "public"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dhcp_options = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}

module "vpc_endpoints" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc//modules//vpc-endpoints?ref=v5.8.1"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
    }
    ingress_http = {
      description = "HTTP from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
    }
  }

  endpoints = {
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    }
  }
}

module "vpc_endpoints_nocreate" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc//modules//vpc-endpoints?ref=v5.8.1"

  create = false
}

################################################################################
# Supporting Resources
################################################################################
data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}