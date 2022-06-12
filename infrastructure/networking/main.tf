# Data sources

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

#####################################
############## VPC ##################
#####################################

resource "aws_vpc" "vpc-image-delivery-service" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "vpc-image-delivery-service"
  }
}

#####################################
######### Internet Gateway ##########
#####################################

resource "aws_internet_gateway" "gw-image-delivery-service" {
  vpc_id = local.vpc_id

  tags = {
    Name = "gw-image-delivery-service"
  }
}

#####################################
######### Public Subnets ############
#####################################

resource "aws_subnet" "public_subnet" {
  count = var.public_sn_count

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.vpc_id}-public-sn-${count.index}"
  }
}

#####################################
######### Private Subnets ###########
#####################################

resource "aws_subnet" "private_subnet" {
  count = var.private_sn_count

  vpc_id            = local.vpc_id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${local.vpc_id}-private-sn-${count.index}"
  }
}

########################################
######### Public Route Table ###########
########################################

resource "aws_route_table" "public_rtb" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${local.vpc_id}-public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw-image-delivery-service.id
}

resource "aws_route_table_association" "public_rtb_association" {
  count = var.public_sn_count

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rtb.id
}

#####################################
########### Nat Gateway #############
#####################################

resource "aws_eip" "eip-image-delivery-service" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway-image-delivery-service" {
  allocation_id = aws_eip.eip-image-delivery-service.id
  subnet_id     = aws_subnet.public_subnet.*.id[0]

  tags = {
    Name = "${local.vpc_id}-nat-gateway-image-delivery-service"
  }
}

resource "aws_default_route_table" "default-route-table" {
  default_route_table_id = aws_vpc.vpc-image-delivery-service.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-image-delivery-service.id
  }

  tags = {
    Name = "${local.vpc_id}-image-delivery-service"
  }
}

#########################################
########### Security Groups #############
#########################################

resource "aws_security_group" "security-group-instance-image-delivery-service" {
  name        = "web_application_sg"
  description = "Security Group for Web Application"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_security_group" "security-group-application-server-image-delivery-service" {
  name        = "application_server_sg"
  description = "Security Group for Application Server"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security-group-alb-public-facing-image-delivery-service" {
  name   = "alb_public_facing_seg"
  vpc_id = local.vpc_id

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
}

resource "aws_security_group" "security-group-alb-internal-image-delivery-service" {
  name   = "alb_internal_seg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security-group-efs-image-delivery-service" {
  name        = "efs_sh"
  description = "Allos inbound efs traffic from ec2"
  vpc_id      = local.vpc_id

  ingress {
    security_groups = [aws_security_group.security-group-instance-image-delivery-service.id]
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
  }

  egress {
    security_groups = [aws_security_group.security-group-instance-image-delivery-service.id]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
}
