variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_security_group" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "instance_iam_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_security_group" {
  type = string
}

variable "image" {
  description = "Name filter for EC2 AMI"
  default     = "amzn-ami-hvm-*-x86_64-gp2"
}