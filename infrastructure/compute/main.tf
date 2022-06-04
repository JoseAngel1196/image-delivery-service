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
  vpc_security_group_ids = [var.web_application_security_group]

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

# resource "aws_instance" "ec2-web-application-image-delivery-service" {
#   instance_type          = local.instance_type
#   ami                    = data.aws_ami.amazon-linux-2.id
#   key_name               = aws_key_pair.aws_auth.id
#   subnet_id              = var.private_subnets[0]
#   vpc_security_group_ids = [var.web_application_security_group]
#   user_data              = file("userdata.tpl")
#   iam_instance_profile   = var.instance_iam_name

#   tags = {
#     Name = "ec2-web-application-image-delivery-service"
#   }
# }

# resource "aws_instance" "ec2-application-server-image-delivery-service" {
#   instance_type          = local.instance_type
#   ami                    = data.aws_ami.amazon-linux-2.id
#   key_name               = aws_key_pair.aws_auth.id
#   subnet_id              = var.private_subnets[6]
#   vpc_security_group_ids = [var.application_server_security_group]
#   user_data              = file("serverdata.tpl")
#   iam_instance_profile   = var.instance_iam_name

#   tags = {
#     Name = "ec2-application-server-image-delivery-service"
#   }
# }

#####################################
###### Launch Configuration #########
#####################################

resource "template_file" "user_data" {
  template = file("userdata.tpl")

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "server_data" {
  template = file("serverdata.tpl")

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_launch_configuration" "front-end-server-launch-configuration-image-delivery-service" {
  name_prefix          = "front-end-server-launch-configuration-image-delivery-service"
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = local.instance_type
  key_name             = aws_key_pair.aws_auth.id
  security_groups      = [var.web_application_security_group]
  user_data            = template_file.user_data.rendered
  iam_instance_profile = var.instance_iam_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "application-server-launch-configuration-image-delivery-service" {
  name_prefix          = "application-server-launch-configuration-image-delivery-service"
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = local.instance_type
  key_name             = aws_key_pair.aws_auth.id
  security_groups      = [var.application_server_security_group]
  user_data            = template_file.server_data.rendered
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
  security_groups    = [var.alb_public_security_group]
  subnets            = [var.public_subnets[0], var.public_subnets[1], var.public_subnets[2], var.public_subnets[3], var.public_subnets[4], var.public_subnets[5]]
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

# Internal ALB

resource "aws_alb" "alb-internal-image-delivery-service" {
  name               = "alb-internal-img"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.alb_internal_security_group]
  subnets            = [var.private_subnets[6], var.private_subnets[7], var.private_subnets[8], var.private_subnets[9], var.private_subnets[10], var.private_subnets[11]]
}

resource "aws_alb_target_group" "alb-internal-target-group-image-delivery-service" {
  name     = "alb-internal-tg-img"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = 5000
  }
}

resource "aws_alb_listener" "listener-internal-http-image-delivery-service" {
  load_balancer_arn = aws_alb.alb-internal-image-delivery-service.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-internal-target-group-image-delivery-service.arn
    type             = "forward"
  }
}

#####################################
####### Auto-scaling group ##########
#####################################

resource "aws_autoscaling_group" "autoscaling-group-front-end-server-image-delivery-service" {
  name                 = "autoscaling-group-front-end-server-image-delivery-service"
  target_group_arns    = [aws_alb_target_group.alb-target-group-image-delivery-service.arn]
  max_size             = 3
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  launch_configuration = aws_launch_configuration.front-end-server-launch-configuration-image-delivery-service.name
  vpc_zone_identifier  = [var.private_subnets[0], var.private_subnets[1], var.private_subnets[2], var.private_subnets[3], var.private_subnets[4], var.private_subnets[5]]
}

resource "aws_autoscaling_group" "autoscaling-group-application-server-image-delivery-service" {
  name                 = "autoscaling-group-application-server-image-delivery-service"
  target_group_arns    = [aws_alb_target_group.alb-internal-target-group-image-delivery-service.arn]
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  force_delete         = true
  launch_configuration = aws_launch_configuration.application-server-launch-configuration-image-delivery-service.name
  vpc_zone_identifier  = [var.private_subnets[6], var.private_subnets[7], var.private_subnets[8], var.private_subnets[9], var.private_subnets[10], var.private_subnets[11]]
}