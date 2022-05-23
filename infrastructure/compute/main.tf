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
############### EC2 ##################
######################################

# Jump Host

resource "aws_instance" "ec2-bastion-host-image-delivery-service" {
  instance_type          = local.instance_type
  ami                    = local.amazon_linux_ami
  key_name               = var.ssh_key_name
  subnet_id              = random_shuffle.public_subnets_id.result[0]
  vpc_security_group_ids = [var.public_security_group]

  tags = {
    Name = "ec2-jump-host-image-delivery-service"
  }
}

# Private Instances

resource "aws_instance" "ec2-private-host-image-delivery-service" {
  count                  = length(var.private_subnets)
  instance_type          = local.instance_type
  ami                    = local.amazon_linux_ami
  key_name               = var.ssh_key_name
  subnet_id              = random_shuffle.private_subnet_ids.result[count.index]
  vpc_security_group_ids = [var.public_security_group]

  tags = {
    Name = "ec2-private-instance-image-delivery-service-${random_id.random_number.dec}"
  }
}

