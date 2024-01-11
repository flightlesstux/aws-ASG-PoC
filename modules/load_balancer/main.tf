variable "config" {}
variable "public_subnet_ids" {}
variable "vpc_id" {}
variable "asg_name" {}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = var.config.load_balancer.name
  internal           = var.config.load_balancer.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  
  tags = merge(
      {
        "Name" = "${var.config.resources.name}-sg"
      },
      var.config.resources.tags
    )
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = var.config.target_group.name
  port     = var.config.target_group.port
  protocol = var.config.target_group.protocol
  vpc_id   = var.vpc_id
  
  tags = merge(
      {
        "Name" = "${var.config.resources.name}-sg"
      },
      var.config.resources.tags
    )
}

# Target Group Attachment to Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}

# Application Load Balancer Attachment to Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.config.target_group.port
  protocol          = var.config.target_group.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.config.launch_template.instance_name}-sg"
  description = "Security group for ALB Public"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

    tags = merge(
      {
        "Name" = "${var.config.launch_template.instance_name}-sg"
      },
      var.config.resources.tags
    )
}