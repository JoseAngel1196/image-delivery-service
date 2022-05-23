variable "max_subnets" {
  type = number
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "cidr_block" {
  type = string
}