### ALB

resource "aws_alb" "bgs_alb" {
  name = "bgs-alb"

  subnets = ["${aws_subnet.bgs_subpbc1.id}",
    "${aws_subnet.bgs_subpbc2.id}",
  ]

  security_groups = ["${aws_security_group.bgs_wan_sg.id}"]
}

resource "aws_alb_target_group" "app" {
  name        = "bgs-ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.VPC_Terraform.id}"
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.bgs_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}