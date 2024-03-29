variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}


variable "public_key_path" {
  type = string
}

variable "private_key_path" {
  type = string
}