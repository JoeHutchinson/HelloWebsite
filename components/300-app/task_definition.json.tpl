[
  {
    "name": "${container_name}",
    "essential": true,
    "privileged": false,
    "memory": ${memory},
    "cpu": ${cpu},
    "image": "${container_image}",
    "taskRoleArn": "${role_arn}",
    "environment": [],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "wget --spider -q localhost:3000/health || exit 1"
      ],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    },
    "portMappings": [
        {
            "containerPort": 3000,
            "hostPort": 3000,
            "protocol": "tcp"
        },
        {
            "containerPort": 8080,
            "hostPort": 8080,
            "protocol": "tcp"
        }
    ],
    "volumesFrom": [],
    "requires_compatibilities": [],
    "mountPoints": [],
    "volume": [],
    "secrets" : [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${container_name}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    }
  }
]