output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
}

output "jumphost_ip" {
  value = module.compute.jumphost_ip
}

# output "private_ip" {
#   value = module.compute.private_ip
# }