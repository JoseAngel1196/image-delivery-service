resource "random_shuffle" "public_subnets_id" {
  input        = var.public_subnets
  result_count = 1
}

resource "random_shuffle" "private_subnet_ids" {
  input = var.private_subnets
}

######################################
############ Key Pair ################
######################################

resource "aws_key_pair" "aws_auth" {
  key_name   = "aws_auth"
  public_key = file(var.public_key_path)
}

######################################
############### EC2 ##################
######################################

# Jump Host

resource "aws_instance" "ec2-bastion-host-image-delivery-service" {
  instance_type          = local.instance_type
  ami                    = local.amazon_linux_ami
  key_name               = aws_key_pair.aws_auth.id
  subnet_id              = random_shuffle.public_subnets_id.result[0]
  vpc_security_group_ids = [var.public_security_group]

  tags = {
    Name = "ec2-jump-host-image-delivery-service"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      identityfile = var.private_key_path
    })
    interpreter = [
      "bash", "-c"
    ]
  }
}

# Private Instances

# resource "aws_instance" "ec2-private-host-image-delivery-service" {
#   count                  = length(var.private_subnets)
#   instance_type          = local.instance_type
#   ami                    = local.amazon_linux_ami
#   key_name               = aws_key_pair.aws_auth.id
#   subnet_id              = random_shuffle.private_subnet_ids.result[count.index]
#   vpc_security_group_ids = [var.public_security_group]
#   user_data = file("userdata.tpl")
#   iam_instance_profile = var.instance_iam_name

#   tags = {
#     Name = "ec2-private-instance-image-delivery-service"
#   }
# }

#####################################
######### Launch template ###########
#####################################

resource "aws_launch_template" "launch_template_image_delivery_service" {
  name = "private-instance-launch-template-image-delivery-service"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    name = var.instance_iam_name
  }

  image_id = local.amazon_linux_ami

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = local.instance_type

  key_name = aws_key_pair.aws_auth.id

  placement {
    availability_zone = "us-east-1"
  }

  vpc_security_group_ids = [var.public_security_group]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "private-instance-launch-template-image-delivery-service"
    }
  }

  user_data = filebase64("userdata.sh")
}

#####################################
## Application Load Balancer (ALB) ##
#####################################

resource "aws_alb" "alb-image-delivery-service" {
  name            = "alb-image-delivery-service"
  security_groups = [var.alb_security_group]
  subnets         = var.private_subnets
}

resource "aws_alb_target_group" "alb-target-group-image-delivery-service" {
  name     = "alb-target-group-image-delivery-service"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_alb_listener" "listener-http-image-delivery-service" {
  load_balancer_arn = aws_alb.alb-image-delivery-service.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-target-group-image-delivery-service.arn
    type             = "forward"
  }
}

#####################################
####### Auto-scaling group ##########
#####################################

# resource "aws_autoscaling_group" "autoscaling-group-image-delivery-service" {
#   name                      = "autoscaling-group-image-delivery-service"
#   max_size                  = 5
#   min_size                  = 2
#   desired_capacity          = 3
#   force_delete              = true
#   launch_template {
#     id      = aws_launch_template.launch_template_image_delivery_service.id
#     version = "$Latest"
#   }
#   vpc_zone_identifier       = var.private_subnets
# }