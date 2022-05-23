variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "ssh_key_name" {
  type = string
}

variable "public_security_group" {
  type = string
}
