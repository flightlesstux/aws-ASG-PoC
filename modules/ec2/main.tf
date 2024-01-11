variable "config" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "nat_gateway_id" {}
variable "private_route_table_id" {}
variable "alb_sg" {}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix     = "${var.config.launch_template.name}-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.config.launch_template.instance_type
  user_data       = base64encode(var.config.launch_template.user_data_script)

  block_device_mappings {
    device_name = var.config.launch_template.ebs.device_name
    ebs {
      volume_size           = var.config.launch_template.ebs.volume_size
      volume_type           = var.config.launch_template.ebs.volume_type
      delete_on_termination = var.config.launch_template.ebs.delete_on_termination
    }
  }

  network_interfaces {
    associate_public_ip_address = var.config.launch_template.network_interfaces.associate_public_ip_address
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = var.config.launch_template.instance_name
      },
      var.config.resources.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    var.alb_sg,
    var.nat_gateway_id, 
    var.private_route_table_id
  ]
}



# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.config.autoscaling.desired_capacity
  max_size             = var.config.autoscaling.max_size
  min_size             = var.config.autoscaling.min_size
  vpc_zone_identifier  = var.private_subnet_ids

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.lt.id
        version            = "$Latest"
      }

      override {
        instance_type = var.config.launch_template.instance_type
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 100
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.config.launch_template.instance_name}-1"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ var.alb_sg ]
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
        "Name" = "${var.config.launch_template.instance_name}-sg-1"
      },
      var.config.resources.tags
    )
}
