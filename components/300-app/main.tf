resource "aws_ecs_cluster" "this" {
  name = local.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.name
  execution_role_arn       = aws_iam_role.ecs_runner_exec_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = 256
  memory                   = 512

  container_definitions = templatefile("${path.module}/task_definition.json.tpl", {
    role_arn                  = aws_iam_role.task_role.arn
    container_image           = local.container_image
    container_name            = local.container_name
    aws_region                = var.region
    memory                    = var.container_memory
    cpu                       = var.container_cpu
  })
}

module "ecs_service" {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs//modules/service?ref=v5.11.2"

  name        = local.container_name
  cluster_arn = aws_ecs_cluster.this.arn

  cpu    = 1024
  memory = 4096

  create_task_definition = false
  task_definition_arn = aws_ecs_task_definition.this.arn

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups.default.arn
      container_name   = local.container_name
      container_port   = 3000
    }
  }

  subnet_ids = data.aws_subnets.private.ids

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Container port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  depends_on = [ aws_ecs_task_definition.this ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.container_name
  retention_in_days = 3
}