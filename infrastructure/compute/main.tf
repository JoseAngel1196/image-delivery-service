# resource "random_shuffle" "public_subnets_id" {
#   input        = var.public_subnets
#   result_count = 1
# }

# resource "random_shuffle" "private_subnet_ids" {
#   input = var.private_subnets
# }

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
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
  ami                    = data.aws_ami.amazon-linux-2.id
  key_name               = aws_key_pair.aws_auth.id
  subnet_id              = var.public_subnets[0]
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
#   instance_type          = local.instance_type
#   ami                    = data.aws_ami.amazon-linux-2.id
#   key_name               = aws_key_pair.aws_auth.id
#   subnet_id              = var.private_subnets[0]
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

# resource "aws_launch_template" "launch_template_image_delivery_service" {
#   name = "private-instance-launch-template-image-delivery-service"

#   iam_instance_profile {
#     name = var.instance_iam_name
#   }

#   image_id = data.aws_ami.image.id
#   instance_type = local.instance_type
#   key_name = aws_key_pair.aws_auth.id

#   placement {
#     availability_zone = "us-east-1"
#   }

#   vpc_security_group_ids = [var.public_security_group]

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "private-instance-launch-template-image-delivery-service"
#     }
#   }

#   user_data = filebase64("userdata.sh")
# }

resource "template_file" "user_data" {
  template = file("userdata.tpl")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "launch-configuration-image-delivery-service" {
  name_prefix          = "private-instance-launch-configuration-image-delivery-service"
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = local.instance_type
  key_name             = aws_key_pair.aws_auth.id
  security_groups      = [var.public_security_group]
  user_data            = template_file.user_data.rendered
  iam_instance_profile = var.instance_iam_name

  lifecycle {
    create_before_destroy = true
  }
}

#####################################
## Application Load Balancer (ALB) ##
#####################################

resource "aws_alb" "alb-image-delivery-service" {
  name               = "alb-image-delivery-service"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = [var.public_subnets[0], var.public_subnets[1], var.public_subnets[2], var.public_subnets[3], var.public_subnets[4], var.public_subnets[5]]
  # idle_timeout =     120
}

resource "aws_alb_target_group" "alb-target-group-image-delivery-service" {
  name     = "alb-tg-image-delivery-service"
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

resource "aws_autoscaling_group" "autoscaling-group-image-delivery-service" {
  name                 = "autoscaling-group-image-delivery-service"
  target_group_arns    = [aws_alb_target_group.alb-target-group-image-delivery-service.arn]
  max_size             = 3
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  launch_configuration = aws_launch_configuration.launch-configuration-image-delivery-service.name
  vpc_zone_identifier  = var.private_subnets
}