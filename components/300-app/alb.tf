module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = local.name

  load_balancer_type = "application"

  internal = false # wouldn't do this normally, but for the sake of the demo

  vpc_id          = data.aws_vpc.selected.id
  subnets         = data.aws_subnets.public.ids

  enable_deletion_protection = false
  #security_groups = []

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "default"
      }
    }
  }

  target_groups = {
    default = {
      name      = "${local.name}-default"
      protocol         = "HTTP"
      port             = local.container_port
      target_type      = "ip"
      create_attachment = false
      deregistration_delay  = 10
      health_check     = {
        path                = "/"
        healthy_threshold   = 2
        interval            = 10
        unhealthy_threshold = 5
      }
    }
  }

  tags = {
    name = local.name
  }
}