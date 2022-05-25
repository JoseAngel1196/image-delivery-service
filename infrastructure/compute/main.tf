resource "random_shuffle" "public_subnets_id" {
  input        = var.public_subnets
  result_count = 1
}

resource "random_shuffle" "private_subnet_ids" {
  input = var.private_subnets
}

resource "random_id" "random_number" {
  byte_length = 2
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

resource "aws_instance" "ec2-private-host-image-delivery-service" {
  count                  = length(var.private_subnets)
  instance_type          = local.instance_type
  ami                    = local.amazon_linux_ami
  key_name               = aws_key_pair.aws_auth.id
  subnet_id              = random_shuffle.private_subnet_ids.result[count.index]
  vpc_security_group_ids = [var.public_security_group]
  user_data = file("userdata.tpl")

  tags = {
    Name = "ec2-private-instance-image-delivery-service-${random_id.random_number.dec}"
  }
}

