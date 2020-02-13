resource "aws_lb" "test" {
  name                       = "TerraformTest"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.elb.id
  ]

  subnets = [for subnet in aws_subnet.managedResources: subnet.id]

  tags = {
    Name = "TerraformTest"
  }
}

resource "aws_lb_target_group" "test" {
  name        = "TerraformTest-HTTP"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test.id
  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "80"
  }
}

resource "aws_autoscaling_attachment" "test" {
  autoscaling_group_name = aws_autoscaling_group.instance.name
  alb_target_group_arn   = aws_lb_target_group.test.arn
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_security_group" "elb" {
  tags   = {
    Name = "TerraformTest ELB SG"
  }
  vpc_id = aws_vpc.test.id
}

resource "aws_security_group_rule" "elb-ingress-http" {
  security_group_id = aws_security_group.elb.id
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 80
  to_port           = 80
  description       = "Allow public HTTP access"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
resource "aws_security_group_rule" "elb-egress-allowAll" {
  security_group_id = aws_security_group.elb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  description       = "Allow all egress rule"

  cidr_blocks       = [
    "0.0.0.0/0"
  ]
}
