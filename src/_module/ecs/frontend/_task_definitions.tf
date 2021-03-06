# 抽象化には課題が多いので一旦 json で運用

# コンテナ定義を呼び出す
#data "template_file" "container_definitions" {
#  template = jsonencode(local.ecs_tasks)
#}

locals {
  ecs_tasks = [
    {
      name         = var.app_name // var.entry_container_name
      image        = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.app_name}:latest"
      command      = ["yarn", "start"]
      essential    = true
      cpu          = 256
      memory       = 512
      network_mode = "awsvpc"
      portMappings = [
        {
          containerPort = "${var.entry_container_port}"
          hostPort      = "${var.entry_container_port}"
          protocol      = "tcp"
        }
      ]

      managedAgents = [
        {
          lastStartedAt = "2021-03-01T14:49:44.574000-06:00"
          name          = "ExecuteCommandAgent"
          lastStatus    = "RUNNING"
        }
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = local.region
          awslogs-group         = "/${var.app_name}/ecs"
          awslogs-stream-prefix = "${var.app_name}-ecs"
        }
      }

      "environment" = [
        {
          name  = "PORT"
          value = tostring(var.entry_container_port)  # number で渡すとコケるのでlocal でstring にしている
        }
      ]
    }
  ]
}

