variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "web_application_security_group" {
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

variable "alb_public_security_group" {
  type = string
}

variable "application_server_security_group" {
  type = string
}

variable "alb_internal_security_group" {
  type = string
}

variable "efs_security_group" {
  type = string
}