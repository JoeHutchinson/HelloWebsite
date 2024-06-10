data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_runner_exec_role" {
  name               = "${local.name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}


data "aws_iam_policy_document" "ecs_exec_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecs:DescribeTaskDefinition",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_exec_policy" {
  name   = "${local.name}-exec-role"
  policy = data.aws_iam_policy_document.ecs_exec_doc.json
  role   = aws_iam_role.ecs_runner_exec_role.id
}


resource "aws_iam_role" "task_role" {
  name = "${local.name}-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}


data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "${local.name}-exec-role"
  policy = data.aws_iam_policy_document.ecs_task_doc.json
  role   = aws_iam_role.task_role.id
}
