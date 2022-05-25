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