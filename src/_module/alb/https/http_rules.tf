# ==================================================================
# TODO::http で zone を指定したあとに切り替えると良い (httpのルール)
# TODO::必ず使用しない場合はコメントアウトすること
# ==================================================================

# =====================================================
# listener
# =====================================================
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# =====================================================
# target
# =====================================================
resource "aws_lb_target_group" "main" {
  name   = var.app_name
  vpc_id = var.vpc_id
  #FargateではIPに設定する必要ある
  target_type = "ip"
  # 80port
  port                 = 80
  deregistration_delay = 300
  protocol             = "HTTP"
  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}